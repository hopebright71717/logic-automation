#!/usr/bin/env python3
"""
Logic 成本追蹤系統 — API 成本計算與記錄

功能：
1. 記錄每次 API 呼叫（timestamp, task, model, tokens, cost）
2. 計算成本（USD 和 TWD）
3. 彙總今日與本月成本
4. 產生成本排行榜（TOP 10 最耗費指令）
"""

import json
import csv
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

# OpenAI 模型單價（per 1K tokens）— 2026-02-01 定價
MODEL_PRICING = {
    "gpt-4": {
        "input": 0.03,
        "output": 0.06
    },
    "gpt-4-turbo": {
        "input": 0.01,
        "output": 0.03
    },
    "gpt-4o": {
        "input": 0.005,
        "output": 0.015
    },
    "gpt-4o-mini": {
        "input": 0.00015,
        "output": 0.0006
    },
    "gpt-3.5-turbo": {
        "input": 0.0005,
        "output": 0.0015
    },
    "o1": {
        "input": 0.015,
        "output": 0.06
    },
    "o1-mini": {
        "input": 0.003,
        "output": 0.012
    }
}

USD_TO_TWD = 30  # 匯率
LOGIC_DIR = Path(__file__).parent.parent
COST_DIR = LOGIC_DIR / "cost"
RAW_CALLS_FILE = COST_DIR / "raw_calls.jsonl"
TODAY_FILE = LOGIC_DIR / "cost_today.json"
MONTH_FILE = LOGIC_DIR / "cost_month.json"
RANK_FILE = LOGIC_DIR / "cost_rank.csv"


class CostTracker:
    def __init__(self):
        """初始化成本追蹤器"""
        COST_DIR.mkdir(parents=True, exist_ok=True)
        
    def calculate_cost(
        self,
        model: str,
        prompt_tokens: int,
        completion_tokens: int
    ) -> Dict[str, float]:
        """
        計算單次 API 呼叫成本
        
        Args:
            model: 模型名稱
            prompt_tokens: 輸入 tokens
            completion_tokens: 輸出 tokens
            
        Returns:
            {"usd": float, "twd": float, "total_tokens": int}
        """
        # 處理模型別名
        model_key = model.lower()
        for key in MODEL_PRICING.keys():
            if key in model_key:
                model_key = key
                break
        
        if model_key not in MODEL_PRICING:
            # 未知模型，使用 gpt-4o 價格作為預估
            model_key = "gpt-4o"
        
        pricing = MODEL_PRICING[model_key]
        
        # 計算成本（per 1K tokens）
        input_cost = (prompt_tokens / 1000) * pricing["input"]
        output_cost = (completion_tokens / 1000) * pricing["output"]
        total_usd = input_cost + output_cost
        total_twd = total_usd * USD_TO_TWD
        total_tokens = prompt_tokens + completion_tokens
        
        return {
            "usd": round(total_usd, 6),
            "twd": round(total_twd, 2),
            "total_tokens": total_tokens
        }
    
    def log_api_call(
        self,
        task_id: str,
        command_summary: str,
        model: str,
        prompt_tokens: int,
        completion_tokens: int
    ) -> Dict:
        """
        記錄一次 API 呼叫
        
        Args:
            task_id: 任務 ID
            command_summary: 指令摘要
            model: 模型名稱
            prompt_tokens: 輸入 tokens
            completion_tokens: 輸出 tokens
            
        Returns:
            記錄的完整資料
        """
        cost = self.calculate_cost(model, prompt_tokens, completion_tokens)
        timestamp = datetime.now().isoformat()
        
        record = {
            "timestamp": timestamp,
            "task_id": task_id,
            "command": command_summary,
            "model": model,
            "prompt_tokens": prompt_tokens,
            "completion_tokens": completion_tokens,
            "total_tokens": cost["total_tokens"],
            "cost_usd": cost["usd"],
            "cost_twd": cost["twd"]
        }
        
        # 寫入 JSONL
        with open(RAW_CALLS_FILE, "a", encoding="utf-8") as f:
            f.write(json.dumps(record, ensure_ascii=False) + "\n")
        
        # 更新彙總
        self._update_summary(record)
        
        return record
    
    def _update_summary(self, record: Dict):
        """更新今日與本月彙總"""
        today_str = datetime.now().strftime("%Y-%m-%d")
        month_str = datetime.now().strftime("%Y-%m")
        
        # 更新今日彙總
        today_data = self._load_json(TODAY_FILE, {
            "date": today_str,
            "total_usd": 0,
            "total_twd": 0,
            "total_tokens": 0,
            "by_model": {},
            "calls_count": 0,
            "last_updated": datetime.now().isoformat()
        })
        
        if today_data["date"] != today_str:
            # 新的一天，重置
            today_data = {
                "date": today_str,
                "total_usd": 0,
                "total_twd": 0,
                "total_tokens": 0,
                "by_model": {},
                "calls_count": 0,
                "last_updated": datetime.now().isoformat()
            }
        
        today_data["total_usd"] += record["cost_usd"]
        today_data["total_twd"] += record["cost_twd"]
        today_data["total_tokens"] += record["total_tokens"]
        today_data["calls_count"] += 1
        today_data["last_updated"] = datetime.now().isoformat()
        
        model = record["model"]
        if model not in today_data["by_model"]:
            today_data["by_model"][model] = {
                "calls": 0,
                "tokens": 0,
                "usd": 0,
                "twd": 0
            }
        today_data["by_model"][model]["calls"] += 1
        today_data["by_model"][model]["tokens"] += record["total_tokens"]
        today_data["by_model"][model]["usd"] += record["cost_usd"]
        today_data["by_model"][model]["twd"] += record["cost_twd"]
        
        self._save_json(TODAY_FILE, today_data)
        
        # 更新本月彙總
        month_data = self._load_json(MONTH_FILE, {
            "month": month_str,
            "total_usd": 0,
            "total_twd": 0,
            "total_tokens": 0,
            "by_model": {},
            "calls_count": 0,
            "budget_usd": 65,
            "budget_twd": 1950,
            "remaining_usd": 65,
            "remaining_twd": 1950,
            "burn_rate_usd_per_day": 0,
            "days_remaining": 28,
            "last_updated": datetime.now().isoformat()
        })
        
        if month_data["month"] != month_str:
            # 新的月份，重置
            month_data = {
                "month": month_str,
                "total_usd": 0,
                "total_twd": 0,
                "total_tokens": 0,
                "by_model": {},
                "calls_count": 0,
                "budget_usd": 65,
                "budget_twd": 1950,
                "remaining_usd": 65,
                "remaining_twd": 1950,
                "burn_rate_usd_per_day": 0,
                "days_remaining": 28,
                "last_updated": datetime.now().isoformat()
            }
        
        month_data["total_usd"] += record["cost_usd"]
        month_data["total_twd"] += record["cost_twd"]
        month_data["total_tokens"] += record["total_tokens"]
        month_data["calls_count"] += 1
        month_data["remaining_usd"] = month_data["budget_usd"] - month_data["total_usd"]
        month_data["remaining_twd"] = month_data["budget_twd"] - month_data["total_twd"]
        month_data["last_updated"] = datetime.now().isoformat()
        
        # 計算燃燒率
        day_of_month = datetime.now().day
        if day_of_month > 0:
            month_data["burn_rate_usd_per_day"] = round(month_data["total_usd"] / day_of_month, 4)
        
        # 計算剩餘天數
        import calendar
        days_in_month = calendar.monthrange(datetime.now().year, datetime.now().month)[1]
        month_data["days_remaining"] = days_in_month - day_of_month
        
        model = record["model"]
        if model not in month_data["by_model"]:
            month_data["by_model"][model] = {
                "calls": 0,
                "tokens": 0,
                "usd": 0,
                "twd": 0
            }
        month_data["by_model"][model]["calls"] += 1
        month_data["by_model"][model]["tokens"] += record["total_tokens"]
        month_data["by_model"][model]["usd"] += record["cost_usd"]
        month_data["by_model"][model]["twd"] += record["cost_twd"]
        
        self._save_json(MONTH_FILE, month_data)
        
        # 更新排行榜
        self._update_rank()
    
    def _update_rank(self):
        """更新成本排行榜（TOP 10）"""
        if not RAW_CALLS_FILE.exists():
            return
        
        # 統計每個 command 的成本
        command_stats = {}
        
        with open(RAW_CALLS_FILE, "r", encoding="utf-8") as f:
            for line in f:
                record = json.loads(line)
                cmd = record["command"]
                model = record["model"]
                
                key = f"{cmd}|{model}"
                if key not in command_stats:
                    command_stats[key] = {
                        "command": cmd,
                        "model": model,
                        "total_calls": 0,
                        "total_tokens": 0,
                        "total_usd": 0,
                        "total_twd": 0,
                        "last_used": record["timestamp"]
                    }
                
                command_stats[key]["total_calls"] += 1
                command_stats[key]["total_tokens"] += record["total_tokens"]
                command_stats[key]["total_usd"] += record["cost_usd"]
                command_stats[key]["total_twd"] += record["cost_twd"]
                command_stats[key]["last_used"] = record["timestamp"]
        
        # 排序（按總成本 USD）
        sorted_stats = sorted(
            command_stats.values(),
            key=lambda x: x["total_usd"],
            reverse=True
        )[:10]  # TOP 10
        
        # 寫入 CSV
        with open(RANK_FILE, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow([
                "command", "model", "total_calls", "total_tokens",
                "total_usd", "total_twd", "avg_tokens", "last_used"
            ])
            
            for stat in sorted_stats:
                avg_tokens = stat["total_tokens"] // stat["total_calls"] if stat["total_calls"] > 0 else 0
                writer.writerow([
                    stat["command"],
                    stat["model"],
                    stat["total_calls"],
                    stat["total_tokens"],
                    round(stat["total_usd"], 4),
                    round(stat["total_twd"], 2),
                    avg_tokens,
                    stat["last_used"]
                ])
    
    def _load_json(self, path: Path, default: Dict) -> Dict:
        """載入 JSON 檔案"""
        if path.exists():
            with open(path, "r", encoding="utf-8") as f:
                return json.load(f)
        return default
    
    def _save_json(self, path: Path, data: Dict):
        """儲存 JSON 檔案"""
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    
    def get_today_summary(self) -> Dict:
        """取得今日成本摘要"""
        return self._load_json(TODAY_FILE, {})
    
    def get_month_summary(self) -> Dict:
        """取得本月成本摘要"""
        return self._load_json(MONTH_FILE, {})
    
    def check_budget_alerts(self) -> List[str]:
        """檢查預算警報"""
        alerts = []
        today = self.get_today_summary()
        month = self.get_month_summary()
        
        # 日成本警報
        today_usd = today.get("total_usd", 0)
        if today_usd >= 3:
            alerts.append(f"🛑 今日成本已達 ${today_usd:.2f} USD（硬上限 $3），停用非必要 API")
        elif today_usd >= 2:
            alerts.append(f"⚠️ 今日成本已達 ${today_usd:.2f} USD（軟上限 $2），建議降級模型")
        
        # 月成本警報
        month_usd = month.get("total_usd", 0)
        budget = month.get("budget_usd", 65)
        
        if month_usd >= budget:
            alerts.append(f"🛑 本月成本已達 ${month_usd:.2f} USD（上限 ${budget}），完全停用 API")
        elif month_usd >= budget * 0.8:
            alerts.append(f"⚠️ 本月成本已達 ${month_usd:.2f} USD（{month_usd/budget*100:.1f}% of ${budget}），接近上限")
        elif month_usd >= budget * 0.5:
            alerts.append(f"ℹ️ 本月成本已達 ${month_usd:.2f} USD（{month_usd/budget*100:.1f}% of ${budget}）")
        
        return alerts


# CLI 接口
if __name__ == "__main__":
    import sys
    
    tracker = CostTracker()
    
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python cost_tracker.py log <task_id> <command> <model> <prompt_tokens> <completion_tokens>")
        print("  python cost_tracker.py summary")
        print("  python cost_tracker.py alerts")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "log":
        if len(sys.argv) != 7:
            print("Error: log requires 5 arguments")
            sys.exit(1)
        
        task_id = sys.argv[2]
        cmd_summary = sys.argv[3]
        model = sys.argv[4]
        prompt_tokens = int(sys.argv[5])
        completion_tokens = int(sys.argv[6])
        
        record = tracker.log_api_call(task_id, cmd_summary, model, prompt_tokens, completion_tokens)
        print(f"✅ Logged: ${record['cost_usd']:.4f} USD / ${record['cost_twd']:.2f} TWD")
    
    elif command == "summary":
        today = tracker.get_today_summary()
        month = tracker.get_month_summary()
        
        print("=== 今日成本 ===")
        print(f"  總額：${today.get('total_usd', 0):.4f} USD / ${today.get('total_twd', 0):.2f} TWD")
        print(f"  呼叫次數：{today.get('calls_count', 0)}")
        print(f"  總 tokens：{today.get('total_tokens', 0):,}")
        
        print("\n=== 本月成本 ===")
        print(f"  總額：${month.get('total_usd', 0):.4f} USD / ${month.get('total_twd', 0):.2f} TWD")
        print(f"  預算：${month.get('budget_usd', 65):.2f} USD")
        print(f"  剩餘：${month.get('remaining_usd', 0):.2f} USD")
        print(f"  燃燒率：${month.get('burn_rate_usd_per_day', 0):.4f} USD/day")
    
    elif command == "alerts":
        alerts = tracker.check_budget_alerts()
        if alerts:
            for alert in alerts:
                print(alert)
        else:
            print("✅ 無預算警報")
    
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)
