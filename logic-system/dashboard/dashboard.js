// Logic 儀表板 JavaScript

const REFRESH_INTERVAL = 5000; // 5 秒刷新一次
const STATUS_FILE = '/status.json';
const COST_TODAY_FILE = '/cost_today.json';
const COST_MONTH_FILE = '/cost_month.json';
const COST_RANK_FILE = '/cost_rank.csv';

// 更新當前時間
function updateTime() {
    const now = new Date();
    const options = {
        timeZone: 'Asia/Taipei',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
    };
    const timeStr = now.toLocaleString('zh-TW', options);
    document.getElementById('currentTime').textContent = timeStr;
}

// 格式化時間（相對時間）
function formatRelativeTime(timestamp) {
    if (!timestamp) return '—';
    const now = new Date();
    const time = new Date(timestamp);
    const diff = Math.floor((now - time) / 1000); // 秒

    if (diff < 60) return `${diff} 秒前`;
    if (diff < 3600) return `${Math.floor(diff / 60)} 分鐘前`;
    if (diff < 86400) return `${Math.floor(diff / 3600)} 小時前`;
    return time.toLocaleString('zh-TW', { timeZone: 'Asia/Taipei', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
}

// 載入狀態資料
async function loadStatus() {
    try {
        const response = await fetch(STATUS_FILE);
        const data = await response.json();

        // 更新當前任務
        document.getElementById('currentTask').textContent = data.current_task?.name || '無';

        const statusBadge = document.getElementById('taskStatus');
        statusBadge.textContent = data.current_task?.status || 'idle';
        statusBadge.className = `value status-badge ${data.current_task?.status || 'idle'}`;

        document.getElementById('taskStartTime').textContent = formatRelativeTime(data.current_task?.started_at);

        const progress = data.current_task?.progress || 0;
        document.getElementById('taskProgress').style.width = `${progress}%`;
        document.getElementById('taskProgressText').textContent = `${progress}%`;

        document.getElementById('lastHeartbeat').textContent = formatRelativeTime(data.last_heartbeat);

        // 更新今日輸出
        const outputsList = document.getElementById('outputsList');
        if (data.today_outputs && data.today_outputs.length > 0) {
            outputsList.innerHTML = data.today_outputs.map(output => `
                <div class="output-item">
                    <span class="output-path">${output.path}</span>
                    <span class="output-time">${formatRelativeTime(output.timestamp)}</span>
                </div>
            `).join('');
        } else {
            outputsList.innerHTML = '<div class="empty-state">今日尚無輸出</div>';
        }

        // 更新錯誤與警告
        const errorsList = document.getElementById('errorsList');
        const allIssues = [
            ...(data.errors || []).map(e => ({ ...e, type: 'error' })),
            ...(data.warnings || []).map(w => ({ ...w, type: 'warning' }))
        ].sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp)).slice(0, 10);

        if (allIssues.length > 0) {
            errorsList.innerHTML = allIssues.map(issue => `
                <div class="${issue.type}-item">
                    <div class="error-time">${formatRelativeTime(issue.timestamp)}</div>
                    <div class="error-message">${issue.message}</div>
                </div>
            `).join('');
        } else {
            errorsList.innerHTML = '<div class="empty-state">無錯誤或警告 ✅</div>';
        }

    } catch (error) {
        console.error('載入狀態失敗:', error);
    }
}

// 載入成本資料
async function loadCost() {
    try {
        // 今日成本
        const todayResponse = await fetch(COST_TODAY_FILE);
        const todayData = await todayResponse.json();

        document.getElementById('costTodayUSD').textContent = `$${todayData.total_usd?.toFixed(4) || '0.0000'}`;
        document.getElementById('costTodayTWD').textContent = `$${todayData.total_twd?.toFixed(2) || '0.00'} TWD`;

        // 本月成本
        const monthResponse = await fetch(COST_MONTH_FILE);
        const monthData = await monthResponse.json();

        document.getElementById('costMonthUSD').textContent = `$${monthData.total_usd?.toFixed(4) || '0.0000'}`;
        document.getElementById('costMonthTWD').textContent = `$${monthData.total_twd?.toFixed(2) || '0.00'} TWD`;

        document.getElementById('remainingUSD').textContent = `$${monthData.remaining_usd?.toFixed(2) || '65.00'}`;

        const budgetPercent = monthData.budget_usd > 0
            ? ((monthData.total_usd / monthData.budget_usd) * 100).toFixed(1)
            : 0;
        document.getElementById('remainingPercent').textContent = `${(100 - budgetPercent).toFixed(1)}%`;
        document.getElementById('budgetPercent').textContent = `${budgetPercent}%`;

        document.getElementById('burnRate').textContent = `$${monthData.burn_rate_usd_per_day?.toFixed(4) || '0.0000'}`;

        // 預算進度條
        document.getElementById('budgetFill').style.width = `${budgetPercent}%`;

        // 根據預算使用率改變顏色
        const budgetFill = document.getElementById('budgetFill');
        if (budgetPercent >= 80) {
            budgetFill.style.background = 'var(--accent-danger)';
        } else if (budgetPercent >= 50) {
            budgetFill.style.background = 'var(--accent-warning)';
        } else {
            budgetFill.style.background = 'var(--accent-success)';
        }

    } catch (error) {
        console.error('載入成本資料失敗:', error);
    }
}

// 載入成本排行
async function loadRank() {
    try {
        const response = await fetch(COST_RANK_FILE);
        const csvText = await response.text();

        const lines = csvText.trim().split('\n');
        if (lines.length <= 1) {
            document.getElementById('rankTableBody').innerHTML =
                '<tr><td colspan="6" class="empty-state">尚無資料</td></tr>';
            return;
        }

        // 解析 CSV（跳過表頭）
        const rows = lines.slice(1, 6).map((line, index) => {
            const [command, model, calls, tokens, usd, twd, avg, lastUsed] = line.split(',');
            return `
                <tr>
                    <td>${index + 1}</td>
                    <td>${command}</td>
                    <td>${model}</td>
                    <td>${calls}</td>
                    <td>${parseInt(tokens).toLocaleString()}</td>
                    <td>$${parseFloat(usd).toFixed(4)}</td>
                </tr>
            `;
        }).join('');

        document.getElementById('rankTableBody').innerHTML = rows ||
            '<tr><td colspan="6" class="empty-state">尚無資料</td></tr>';

    } catch (error) {
        console.error('載入排行資料失敗:', error);
        document.getElementById('rankTableBody').innerHTML =
            '<tr><td colspan="6" class="empty-state">尚無資料</td></tr>';
    }
}

// 重新載入所有資料
async function refreshAll() {
    updateTime();
    await Promise.all([
        loadStatus(),
        loadCost(),
        loadRank()
    ]);

    document.getElementById('lastUpdate').textContent = new Date().toLocaleTimeString('zh-TW', {
        timeZone: 'Asia/Taipei',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    });
}

// 初始化
document.addEventListener('DOMContentLoaded', () => {
    // 立即載入一次
    refreshAll();

    // 定期刷新
    setInterval(refreshAll, REFRESH_INTERVAL);

    // 每秒更新時間
    setInterval(updateTime, 1000);
});
