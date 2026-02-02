"""
驊原智慧通訊 - 社群媒體內容生成系統
用途：自動生成多平台社群內容供選擇
"""

import os
import schedule
import time
from datetime import datetime
from dotenv import load_dotenv
import openai
import json

# 載入配置
load_dotenv('config/.env')

class SocialMediaContentGenerator:
    """社群媒體內容生成器"""
    
    def __init__(self):
        self.openai_key = os.getenv('OPENAI_API_KEY')
        self.telegram_token = os.getenv('TELEGRAM_BOT_TOKEN')
        self.chat_id = os.getenv('TELEGRAM_CHAT_ID')
        
        openai.api_key = self.openai_key
        
        # 載入知識庫
        self.load_knowledge_base()
        
        print("🤖 社群媒體內容生成器初始化中...")
        print("🤖 Social Media Content Generator initializing...")
        
    def load_knowledge_base(self):
        """載入公司知識庫"""
        print("\n📚 載入知識庫...")
        print("📚 Loading knowledge base...")
        
        # TODO: 從knowledge/company_info.md讀取
        self.company_info = {
            "name": "驊原智慧通訊",
            "product": "PTT 按鈕",
            "target": "對講機用戶"
        }
        
    def generate_threads_content(self, time_slot):
        """
        生成 Threads 貼文
        
        Args:
            time_slot: 'morning', 'noon', 'evening'
        
        Returns:
            list: 3 個版本的貼文
        """
        print(f"\n✍️ 生成 Threads {time_slot} 內容...")
        print(f"✍️ Generating Threads {time_slot} content...")
        
        prompts = {
            'morning': "產品功能介紹，專業簡潔，100-200字",
            'noon': "用戶應用場景，真實案例，100-200字",
            'evening': "行業趨勢或AI話題，吸引討論，100-200字"
        }
        
        system_prompt = f"""
        你是驊原智慧通訊的社群媒體專家。
        
        任務：生成 Threads 貼文
        時段：{time_slot}
        要求：{prompts[time_slot]}
        
        格式：
        - 吸引人的開頭
        - 清晰的重點
        - 相關 hashtag（2-3個）
        - 專業但易懂
        
        生成 1 個版本。
        """
        
        try:
            response = openai.chat.completions.create(
                model="gpt-4o-mini",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": "生成貼文"}
                ]
            )
            content = response.choices[0].message.content
            return content
        except Exception as e:
            print(f"❌ 錯誤：{e}")
            print(f"❌ Error: {e}")
            return None
    
    def send_to_telegram(self, content_type, content):
        """
        通過 Telegram 發送內容
        
        Args:
            content_type: 內容類型
            content: 生成的內容
        """
        print(f"\n📤 發送到 Telegram...")
        print(f"📤 Sending to Telegram...")
        
        # TODO: 實現 Telegram 通知
        print(f"內容類型：{content_type}")
        print(f"Content type: {content_type}")
        print(f"\n{content}")
    
    def run_schedule(self):
        """執行定時任務"""
        print("\n🚀 社群媒體內容生成器啟動！")
        print("🚀 Social Media Content Generator started!")
        print("")
        
        # 設置定時任務
        schedule.every().day.at("09:00").do(
            self.generate_and_send, "threads_morning"
        )
        schedule.every().day.at("12:00").do(
            self.generate_and_send, "threads_noon"
        )
        schedule.every().day.at("18:00").do(
            self.generate_and_send, "threads_evening"
        )
        
        print("⏰ 定時任務已設置：")
        print("⏰ Scheduled tasks set:")
        print("   - 09:00: Threads 早班")
        print("   - 12:00: Threads 午班")
        print("   - 18:00: Threads 晚班")
        print("")
        
        while True:
            schedule.run_pending()
            time.sleep(60)
    
    def generate_and_send(self, content_type):
        """生成並發送內容"""
        if content_type == "threads_morning":
            content = self.generate_threads_content("morning")
        elif content_type == "threads_noon":
            content = self.generate_threads_content("noon")
        elif content_type == "threads_evening":
            content = self.generate_threads_content("evening")
        
        if content:
            self.send_to_telegram(content_type, content)
    
    def test_generate(self):
        """測試生成功能"""
        print("\n🧪 測試內容生成...")
        print("🧪 Testing content generation...")
        
        content = self.generate_threads_content("morning")
        if content:
            print("\n✅ 生成成功！")
            print("✅ Generation successful!")
            print(f"\n{content}")
        else:
            print("\n❌ 生成失敗")
            print("❌ Generation failed")

if __name__ == "__main__":
    generator = SocialMediaContentGenerator()
    
    # 測試模式
    generator.test_generate()
    
    # 正式運行
    # generator.run_schedule()
