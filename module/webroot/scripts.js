// ─── Paths ────────────────────────────────────────────────────────────────────
const MODDIR         = "/data/adb/modules/auto_target";
const PROP           = `${MODDIR}/module.prop`;

const UPDATE              = `${MODDIR}/scripts/update_target.sh`;
const CLEAR               = `${MODDIR}/scripts/clear_target.sh`;
const VIEW                = `${MODDIR}/scripts/view_target.sh`;
const START_MONITOR       = `${MODDIR}/action.sh`;
const STOP_MONITOR        = `${MODDIR}/action.sh`;
const ADD_CUSTOM          = `${MODDIR}/scripts/add_custom.sh`;
const REMOVE_CUSTOM       = `${MODDIR}/scripts/remove_custom.sh`;
const LIST_CUSTOM         = `${MODDIR}/scripts/list_custom.sh`;
const SECURITY_PATCH      = `${MODDIR}/scripts/auto_security_patch.sh`;
const CLEAR_TRACES        = `${MODDIR}/scripts/clear_all_detection_traces.sh`;
const TEE                 = `${MODDIR}/scripts/auto_fix_broken_tee.sh`;
const VIEW_PROPS          = `${MODDIR}/scripts/view_props.sh`;
const RESET_PROPS         = `${MODDIR}/scripts/reset_props.sh`;
const RUN_ALL             = `${MODDIR}/scripts/run_all.sh`;
const GET_APPLIST         = `${MODDIR}/scripts/get_applist.sh`;
const TOGGLE_BLOCKED      = `${MODDIR}/scripts/toggle_blocked.sh`;
const SET_INTERVAL        = `${MODDIR}/scripts/set_monitor_interval.sh`;
const CONFIG_INTERVAL     = `${MODDIR}/config/monitor_interval`;
const DESELECT_UNNECESSARY= `${MODDIR}/scripts/deselect_unnecessary.sh`;
const KEYBOX_MANAGER      = `${MODDIR}/scripts/keybox_manager.sh`;
const TARGET_EDITOR       = `${MODDIR}/scripts/target_editor.sh`;
const BACKUP_TARGET       = `${MODDIR}/scripts/backup_target.sh`;
const GET_STATS           = `${MODDIR}/scripts/get_stats.sh`;
const BOOT_LOG_FLAG       = `${MODDIR}/config/boot_log_enabled`;
const LOG_DIR             = `${MODDIR}/logs`;

// ─── State ────────────────────────────────────────────────────────────────────
let lineCount  = 0;
let allApps    = [];   // [{p, b}]
let activeFilter = "all";

// ─── Shell Helpers ────────────────────────────────────────────────────────────
function isMMRL() {
  return navigator.userAgent.includes("com.dergoogler.mmrl");
}

function runShell(cmd, ignoreError = false) {
  return new Promise((resolve, reject) => {
    if (typeof ksu === "object" && typeof ksu.exec === "function") {
      const cbName = `cb_${Date.now()}`;
      window[cbName] = (code, stdout, stderr) => {
        delete window[cbName];
        if (code === 0 || ignoreError) resolve(stdout);
        else reject(stderr || stdout || "Shell error");
      };
      ksu.exec(cmd, "{}", cbName);
      return;
    }
    if (isMMRL() && typeof window.execShell === "function") {
      window.execShell(cmd).then(resolve).catch(e => reject(e || "Shell error"));
      return;
    }
    reject("No supported shell API found");
  });
}

// ─── UI Helpers ───────────────────────────────────────────────────────────────
function popup(msg) {
  const toast = document.getElementById("toast");
  toast.textContent = msg;
  toast.classList.add("show");
  setTimeout(() => toast.classList.remove("show"), 3000);
}

function logOutput(text) {
  const log = document.getElementById("output-log");
  for (const line of text.trim().split("\n")) {
    lineCount++;
    const pre = document.createElement("pre");
    pre.textContent = `${lineCount.toString().padStart(3, " ")} | ${line}`;
    log.appendChild(pre);
    log.scrollTop = log.scrollHeight;
  }
}

function clearOutput() {
  lineCount = 0;
  document.getElementById("output-log").innerHTML = "";
}

// ─── Module Name ──────────────────────────────────────────────────────────────
async function getModuleName() {
  try {
    const name = await runShell(`grep '^name=' ${PROP} | cut -d= -f2`);
    document.getElementById("module-name").textContent = name.trim();
    document.title = name.trim();
  } catch {
    document.getElementById("module-name").textContent = "AutoTarget";
  }
}

// ─── Script Runners ───────────────────────────────────────────────────────────
async function executeScript(scriptPath, label) {
  popup(label);
  clearOutput();
  logOutput(`[*] ${label}...`);
  try {
    const out = await runShell(`sh ${scriptPath}`);
    logOutput(out || "[+] Done");
  } catch (e) {
    logOutput(`[!] Error: ${e}`);
  }
}

async function executeScriptWithArg(scriptPath, arg, label) {
  popup(label);
  clearOutput();
  logOutput(`[*] ${label}...`);
  try {
    const out = await runShell(`sh ${scriptPath} ${arg}`);
    logOutput(out || "[+] Done");
  } catch (e) {
    logOutput(`[!] Error: ${e}`);
  }
}

// ─── List Viewers ─────────────────────────────────────────────────────────────
async function viewList() {
  popup("Loading list...");
  clearOutput();
  try {
    const out = await runShell(`sh ${VIEW}`);
    out.trim() ? logOutput(out) : logOutput("[*] List is empty");
  } catch (e) {
    logOutput(`[!] Error: ${e}`);
  }
}

async function viewCustomList() {
  popup("Loading custom list...");
  clearOutput();
  try {
    const out = await runShell(`sh ${LIST_CUSTOM}`);
    logOutput(out);
  } catch (e) {
    logOutput(`[!] Error: ${e}`);
  }
}

function getCustomPackage() {
  return document.getElementById("custom-package-input").value.trim();
}

// ─── Props ────────────────────────────────────────────────────────────────────
function getPropsFilter() {
  return document.getElementById("props-filter-input").value.trim();
}

async function viewProps() {
  const filter = getPropsFilter();
  if (!filter) { popup("Enter a filter pattern first"); return; }
  popup("Fetching props...");
  clearOutput();
  logOutput(`[*] Looking for props matching: ${filter}`);
  try {
    const out = await runShell(`sh ${VIEW_PROPS} "${filter}"`);
    logOutput(out || "[*] No matching props found");
  } catch (e) {
    logOutput(`[!] Error: ${e}`);
  }
}

async function resetProps() {
  const filter = getPropsFilter();
  if (!filter) { popup("Enter a filter pattern first"); return; }
  popup("Resetting props...");
  clearOutput();
  logOutput(`[*] Resetting props matching: ${filter}`);
  try {
    const out = await runShell(`sh ${RESET_PROPS} "${filter}"`);
    logOutput(out || "[+] Done");
  } catch (e) {
    logOutput(`[!] Error: ${e}`);
  }
}

// ─── Tools Terminal ───────────────────────────────────────────────────────────
let toolsLineCount = 0;

function logTools(text) {
  const log = document.getElementById("tools-output-log");
  for (const line of String(text).trim().split("\n")) {
    toolsLineCount++;
    const pre = document.createElement("pre");
    pre.textContent = `${toolsLineCount.toString().padStart(3, " ")} | ${line}`;
    log.appendChild(pre);
    log.scrollTop = log.scrollHeight;
  }
}

function clearToolsOutput() {
  toolsLineCount = 0;
  document.getElementById("tools-output-log").innerHTML = "";
}

async function toolsRun(cmd, label) {
  if (label) { popup(label); clearToolsOutput(); logTools(`[*] ${label}...`); }
  try {
    const out = await runShell(cmd);
    logTools(out || "[+] Done");
  } catch (e) {
    logTools(`[!] Error: ${e}`);
  }
}

// ─── Stats ────────────────────────────────────────────────────────────────────
async function refreshStats() {
  try {
    const raw = await runShell(`sh ${GET_STATS}`, true);
    const jsonLine = raw.split("\n").find(l => l.trim().startsWith("{"));
    if (!jsonLine) return;
    const s = JSON.parse(jsonLine.trim());
    document.getElementById("stat-targeted").textContent = s.targeted ?? "–";
    document.getElementById("stat-blocked").textContent  = s.blocked  ?? "–";
    document.getElementById("stat-total").textContent    = s.total    ?? "–";
  } catch { /* silent */ }
}

// ─── Target Editor ────────────────────────────────────────────────────────────
async function editorLoad() {
  const ta = document.getElementById("target-editor");
  ta.value = "Loading...";
  try {
    const out = await runShell(`sh ${TARGET_EDITOR} read`);
    ta.value = out;
    popup("Loaded");
  } catch (e) {
    ta.value = "";
    popup(`Error: ${e}`);
  }
}

async function editorSave() {
  const content = document.getElementById("target-editor").value;
  if (!content.trim()) { popup("Editor is empty"); return; }
  const b64 = btoa(unescape(encodeURIComponent(content)));
  clearToolsOutput();
  try {
    const out = await runShell(`sh ${TARGET_EDITOR} write "${b64}"`);
    logTools(out || "[+] Saved");
    popup("Saved!");
    refreshStats();
  } catch (e) {
    logTools(`[!] Error: ${e}`);
  }
}

// ─── Backup & Restore ─────────────────────────────────────────────────────────
function getBackupFilename() {
  return document.getElementById("backup-filename-input").value.trim();
}

// ─── Keybox ───────────────────────────────────────────────────────────────────
function getKeyboxInput() {
  return document.getElementById("keybox-input").value.trim();
}

// ─── Boot Log Toggle ──────────────────────────────────────────────────────────
async function initBootLogToggle() {
  const toggle = document.getElementById("bootlog-toggle");

  // Read current flag from device (default 1 = enabled)
  try {
    const val = await runShell(`cat ${BOOT_LOG_FLAG} 2>/dev/null || echo 1`);
    toggle.checked = val.trim() !== "0";
  } catch {
    toggle.checked = true;
  }

  toggle.addEventListener("change", async () => {
    const val = toggle.checked ? "1" : "0";
    try {
      await runShell(`mkdir -p $(dirname ${BOOT_LOG_FLAG}) && echo ${val} > ${BOOT_LOG_FLAG}`);
      popup(toggle.checked ? "Boot log enabled" : "Boot log disabled");
    } catch (e) {
      popup(`Error: ${e}`);
    }
  });
}

// ─── Quick Action ─────────────────────────────────────────────────────────────
async function runAllAction() {
  const btn = document.getElementById("action-btn");
  btn.disabled = true;
  btn.textContent = "Running...";
  popup("Running all root-hide scripts...");
  clearOutput();
  try {
    const out = await runShell(`sh ${RUN_ALL}`);
    logOutput(out || "[✓] Done");
  } catch (e) {
    logOutput(`[!] Error: ${e}`);
  }
  popup("Done!");
  btn.disabled = false;
  btn.textContent = "Run All";
}

// ─── Tab System ───────────────────────────────────────────────────────────────
function initTabs() {
  const btns = document.querySelectorAll(".tab-btn");
  btns.forEach(btn => {
    btn.addEventListener("click", () => {
      const target = btn.dataset.tab;
      btns.forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      document.querySelectorAll(".tab-content").forEach(c => c.classList.remove("active"));
      document.getElementById(`tab-${target}`).classList.add("active");
      // Load apps only on first visit — refresh is manual after that
      if (target === "apps" && allApps.length === 0) loadAppList();
    });
  });
}

// ─── App Manager ─────────────────────────────────────────────────────────────
async function loadAppList() {
  const loading = document.getElementById("apps-loading");
  const list    = document.getElementById("apps-list");
  const empty   = document.getElementById("apps-empty");

  // In-memory cache (same JS session)
  if (allApps.length > 0) { renderApps(); return; }

  // localStorage cache with 5-minute TTL
  try {
    const raw  = localStorage.getItem("at_applist");
    const ts   = parseInt(localStorage.getItem("at_applist_ts") || "0", 10);
    const age  = Date.now() - ts;
    if (raw && age < 5 * 60 * 1000) {
      allApps = JSON.parse(raw);
      if (allApps.length > 0) { renderApps(); return; }
    }
  } catch { /* ignore */ }

  loading.style.display = "flex";
  loading.innerHTML = `<div class="spinner"></div><span>Loading...</span>`;
  list.style.display  = "none";
  empty.style.display = "none";

  try {
    const raw = await runShell(`sh ${GET_APPLIST}`);
    allApps = [];
    for (const line of raw.trim().split("\n")) {
      if (!line.trim()) continue;
      try { allApps.push(JSON.parse(line)); } catch { /* skip */ }
    }
    try {
      localStorage.setItem("at_applist",    JSON.stringify(allApps));
      localStorage.setItem("at_applist_ts", String(Date.now()));
    } catch { /* ignore */ }
    renderApps();
  } catch (e) {
    loading.style.display = "none";
    empty.textContent     = `[!] Failed to load: ${e}`;
    empty.style.display   = "block";
  }
}

function renderApps() {
  const loading = document.getElementById("apps-loading");
  const listEl  = document.getElementById("apps-list");
  const empty   = document.getElementById("apps-empty");
  const search  = document.getElementById("app-search").value.toLowerCase();

  const filtered = allApps.filter(app => {
    const matchSearch = !search ||
      app.p.toLowerCase().includes(search) ||
      (app.n && app.n.toLowerCase().includes(search));
    const matchFilter =
      activeFilter === "all" ? true :
      activeFilter === "on"  ? !app.b :
      activeFilter === "off" ?  app.b : true;
    return matchSearch && matchFilter;
  });

  loading.style.display = "none";

  if (filtered.length === 0) {
    listEl.style.display  = "none";
    empty.style.display   = "block";
    empty.textContent     = allApps.length === 0 ? "No apps found" : "No apps match your search";
    return;
  }

  empty.style.display  = "none";
  listEl.style.display = "flex";
  listEl.innerHTML     = "";

  const frag = document.createDocumentFragment();

  for (const app of filtered) {
    const item = document.createElement("div");
    item.className = `app-item${app.b ? " blocked" : ""}`;
    item.dataset.pkg = app.p;

    const displayName = (app.n && app.n !== app.p) ? app.n : "";

    item.innerHTML = `
      <div class="app-info">
        ${displayName ? `<div class="app-name">${displayName}</div>` : ""}
        <div class="app-pkg${displayName ? " app-pkg-small" : ""}">${app.p}</div>
        <span class="app-badge ${app.b ? "off" : "on"}">${app.b ? "Blocked" : "Targeted"}</span>
      </div>
      <div class="app-checkbox-wrap"></div>`;

    item.addEventListener("click", () => toggleAppBlocked(app));
    frag.appendChild(item);
  }

  listEl.appendChild(frag);
}

async function toggleAppBlocked(app) {
  const newBlocked = app.b ? 0 : 1;
  const action     = newBlocked === 1 ? "Blocking" : "Unblocking";
  popup(`${action} ${app.p}...`);

  // Optimistic UI update
  app.b = newBlocked;
  renderApps();

  try {
    await runShell(`sh ${TOGGLE_BLOCKED} "${app.p}" ${newBlocked}`);
    popup(newBlocked ? "Blocked ✓" : "Unblocked ✓");
  } catch (e) {
    // Revert on error
    app.b = newBlocked ? 0 : 1;
    renderApps();
    popup(`Error: ${e}`);
  }

  try {
    localStorage.setItem("at_applist",    JSON.stringify(allApps));
    localStorage.setItem("at_applist_ts", String(Date.now()));
  } catch { /* ignore */ }
}

// ─── Settings Panel ───────────────────────────────────────────────────────────
function initSettings() {
  const btn     = document.getElementById("settings-btn");
  const panel   = document.getElementById("settings-panel");
  const overlay = document.getElementById("settings-overlay");
  const close   = document.getElementById("settings-close");

  const open  = () => { panel.classList.add("open"); overlay.classList.add("open"); btn.classList.add("open"); };
  const close_ = () => { panel.classList.remove("open"); overlay.classList.remove("open"); btn.classList.remove("open"); };

  btn.addEventListener("click", () => panel.classList.contains("open") ? close_() : open());
  close.addEventListener("click", close_);
  overlay.addEventListener("click", close_);
}

// ─── Monitor Interval ─────────────────────────────────────────────────────────
async function initIntervalSetting() {
  const input = document.getElementById("interval-input");
  const save  = document.getElementById("interval-save-btn");

  // Load current value
  try {
    const val = await runShell(`cat ${CONFIG_INTERVAL} 2>/dev/null || echo 60`);
    input.value = val.trim();
  } catch {
    input.value = 60;
  }

  save.addEventListener("click", async () => {
    const val = parseInt(input.value, 10);
    if (!val || val < 10) { popup("Min 10 seconds"); return; }
    save.disabled = true;
    save.textContent = "...";
    try {
      await runShell(`sh ${SET_INTERVAL} ${val}`);
      popup(`Interval set to ${val}s`);
    } catch (e) {
      popup(`Error: ${e}`);
    }
    save.disabled = false;
    save.textContent = "Save";
  });
}

// ─── Toggles (visibility) ─────────────────────────────────────────────────────
function makeToggle(toggleId, targetId, storageKey, byId = true) {
  const toggle = document.getElementById(toggleId);
  const el     = byId ? document.getElementById(targetId) : document.querySelector(targetId);
  const saved  = localStorage.getItem(storageKey);

  if (saved === "1") { el.style.display = ""; toggle.checked = true; }

  toggle.addEventListener("change", () => {
    el.style.display = toggle.checked ? "" : "none";
    localStorage.setItem(storageKey, toggle.checked ? "1" : "0");
  });
}

// ─── Apps Tab Toggle ──────────────────────────────────────────────────────────
function initAppsToggle() {
  const toggle = document.getElementById("apps-toggle");
  const tabBtn = document.getElementById("apps-tab-btn");
  const saved  = localStorage.getItem("showApps");

  if (saved === "1") {
    tabBtn.style.display = "";
    toggle.checked = true;
  }

  toggle.addEventListener("change", () => {
    if (toggle.checked) {
      tabBtn.style.display = "";
      localStorage.setItem("showApps", "1");
    } else {
      // If currently on apps tab, switch back to main first
      if (tabBtn.classList.contains("active")) {
        document.querySelector(".tab-btn[data-tab='main']").click();
      }
      tabBtn.style.display = "none";
      localStorage.setItem("showApps", "0");
    }
  });
}


function initFilterBtns() {
  document.querySelectorAll(".filter-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".filter-btn").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      activeFilter = btn.dataset.filter;
      renderApps();
    });
  });
}

// ─── Repaint ──────────────────────────────────────────────────────────────────
function forceRepaint() {
  document.body.style.display = "none";
  void document.body.offsetHeight;
  document.body.style.display = "";
}

function initTheme() {
  const toggle = document.getElementById("theme-toggle");
  const saved  = localStorage.getItem("theme");

  if (saved === "dark") { document.documentElement.classList.add("dark"); toggle.checked = true; }
  else { document.documentElement.classList.remove("dark"); toggle.checked = false; }

  toggle.addEventListener("change", () => {
    document.documentElement.classList.toggle("dark", toggle.checked);
    localStorage.setItem("theme", toggle.checked ? "dark" : "light");
    forceRepaint();
  });
}

// ─── Init ─────────────────────────────────────────────────────────────────────
document.addEventListener("DOMContentLoaded", () => {
  getModuleName();
  initTheme();
  initSettings();
  initTabs();
  initFilterBtns();
  initIntervalSetting();
  initBootLogToggle();
  setTimeout(refreshStats, 500); // slight delay — shell API needs to be ready

  // Visibility toggles
  makeToggle("action-toggle", "action-card",  "showAction");
  makeToggle("props-toggle",  "props-card",   "showProps");
  makeToggle("tee-toggle",    "tee-btn-wrap", "showTee");
  initAppsToggle();

  // Apps refresh
  document.getElementById("apps-refresh-btn").addEventListener("click", () => {
    allApps = [];
    try {
      localStorage.removeItem("at_applist");
      localStorage.removeItem("at_applist_ts");
    } catch { /* ignore */ }
    loadAppList();
  });

  // Main Controls
  document.getElementById("update-btn")
    .addEventListener("click", () => { executeScript(UPDATE, "Updating target list"); refreshStats(); });
  document.getElementById("clear-btn")
    .addEventListener("click", () => { executeScript(CLEAR, "Clearing target list"); refreshStats(); });
  document.getElementById("view-btn")
    .addEventListener("click", viewList);

  // Monitor
  document.getElementById("start-monitor-btn")
    .addEventListener("click", () => executeScript(`${START_MONITOR} enable`, "Starting monitor"));
  document.getElementById("stop-monitor-btn")
    .addEventListener("click", () => executeScript(`${STOP_MONITOR} disable`, "Stopping monitor"));

  // Custom Packages
  document.getElementById("add-custom-btn").addEventListener("click", () => {
    const pkg = getCustomPackage();
    pkg ? executeScriptWithArg(ADD_CUSTOM, pkg, "Adding custom package") : popup("Enter a package name");
  });
  document.getElementById("remove-custom-btn").addEventListener("click", () => {
    const pkg = getCustomPackage();
    pkg ? executeScriptWithArg(REMOVE_CUSTOM, pkg, "Removing custom package") : popup("Enter a package name");
  });
  document.getElementById("view-custom-btn").addEventListener("click", viewCustomList);

  // Security Tools
  document.getElementById("security-patch-btn")
    .addEventListener("click", () => executeScript(SECURITY_PATCH, "Running security patch"));
  document.getElementById("clear-traces-btn")
    .addEventListener("click", () => executeScript(CLEAR_TRACES, "Clearing detection traces"));
  document.getElementById("fix-tee-btn")
    .addEventListener("click", () => executeScript(TEE, "Fixing TEE"));
  document.getElementById("deselect-unnecessary-btn")
    .addEventListener("click", () => { executeScript(DESELECT_UNNECESSARY, "Deselecting unnecessary apps"); refreshStats(); });

  // Quick Action
  document.getElementById("action-btn").addEventListener("click", runAllAction);

  // Reset Props
  document.getElementById("view-props-btn").addEventListener("click", viewProps);
  document.getElementById("reset-props-btn").addEventListener("click", resetProps);

  // Terminal (main)
  document.getElementById("clear-output").addEventListener("click", clearOutput);

  // ── Tools Tab ──────────────────────────────────────────────────────────────

  // Target Editor
  document.getElementById("editor-load-btn").addEventListener("click", editorLoad);
  document.getElementById("editor-save-btn").addEventListener("click", editorSave);

  // Backup & Restore
  document.getElementById("backup-create-btn").addEventListener("click", () =>
    toolsRun(`sh ${BACKUP_TARGET} create`, "Creating backup"));
  document.getElementById("backup-list-btn").addEventListener("click", () =>
    toolsRun(`sh ${BACKUP_TARGET} list`, "Listing backups"));
  document.getElementById("backup-restore-btn").addEventListener("click", () => {
    const f = getBackupFilename();
    if (!f) { popup("Enter backup filename"); return; }
    toolsRun(`sh ${BACKUP_TARGET} restore "${f}"`, `Restoring ${f}`);
    refreshStats();
  });
  document.getElementById("backup-delete-btn").addEventListener("click", () => {
    const f = getBackupFilename();
    if (!f) { popup("Enter backup filename"); return; }
    toolsRun(`sh ${BACKUP_TARGET} delete "${f}"`, `Deleting ${f}`);
  });

  // Keybox
  document.getElementById("keybox-url-btn").addEventListener("click", () => {
    const u = getKeyboxInput();
    if (!u) { popup("Enter a URL"); return; }
    toolsRun(`sh ${KEYBOX_MANAGER} url "${u}"`, "Loading keybox from URL");
  });
  document.getElementById("keybox-file-btn").addEventListener("click", () => {
    const p = getKeyboxInput();
    if (!p) { popup("Enter a file path"); return; }
    toolsRun(`sh ${KEYBOX_MANAGER} file "${p}"`, "Loading keybox from file");
  });
  document.getElementById("keybox-backup-btn").addEventListener("click", () =>
    toolsRun(`sh ${KEYBOX_MANAGER} backup`, "Backing up keybox"));
  document.getElementById("keybox-restore-btn").addEventListener("click", () =>
    toolsRun(`sh ${KEYBOX_MANAGER} restore`, "Restoring keybox backup"));

  // Boot Logs
  document.getElementById("logs-list-btn").addEventListener("click", () =>
    toolsRun(`ls -1t ${LOG_DIR}/*.log 2>/dev/null | xargs -I{} basename {} || echo "[*] No logs found"`, "Listing logs"));
  document.getElementById("logs-view-btn").addEventListener("click", () =>
    toolsRun(`cat $(ls -1t ${LOG_DIR}/*.log 2>/dev/null | head -n1) 2>/dev/null || echo "[*] No logs found"`, "Loading latest log"));
  document.getElementById("logs-read-btn").addEventListener("click", () => {
    const f = document.getElementById("log-filename-input").value.trim();
    if (!f) { popup("Enter log filename"); return; }
    toolsRun(`cat ${LOG_DIR}/"${f}" 2>/dev/null || echo "[!] Log not found"`, `Reading ${f}`);
  });
  document.getElementById("logs-delete-btn").addEventListener("click", () => {
    const f = document.getElementById("log-filename-input").value.trim();
    if (!f) { popup("Enter log filename"); return; }
    toolsRun(`rm -f ${LOG_DIR}/"${f}" && echo "[+] Deleted" || echo "[!] Not found"`, `Deleting ${f}`);
  });

  // Tools terminal clear
  document.getElementById("clear-tools-output").addEventListener("click", clearToolsOutput);

  // App search
  document.getElementById("app-search").addEventListener("input", () => renderApps());
});
