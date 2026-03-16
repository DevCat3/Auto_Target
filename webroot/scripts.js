// ─── Paths ────────────────────────────────────────────────────────────────────
const MODDIR         = "/data/adb/modules/auto_target";
const PROP           = `${MODDIR}/module.prop`;

const UPDATE         = `${MODDIR}/scripts/update_target.sh`;
const CLEAR          = `${MODDIR}/scripts/clear_target.sh`;
const VIEW           = `${MODDIR}/scripts/view_target.sh`;
const START_MONITOR  = `${MODDIR}/action.sh`;
const STOP_MONITOR   = `${MODDIR}/action.sh`;
const ADD_CUSTOM     = `${MODDIR}/scripts/add_custom.sh`;
const REMOVE_CUSTOM  = `${MODDIR}/scripts/remove_custom.sh`;
const LIST_CUSTOM    = `${MODDIR}/scripts/list_custom.sh`;
const SECURITY_PATCH = `${MODDIR}/scripts/auto_security_patch.sh`;
const CLEAR_TRACES   = `${MODDIR}/scripts/clear_all_detection_traces.sh`;
const BOOT_HASH      = `${MODDIR}/scripts/auto_boot_hash.sh`;
const TEE            = `${MODDIR}/scripts/auto_fix_broken_tee.sh`;

// ─── State ────────────────────────────────────────────────────────────────────
let lineCount = 0;

// ─── Shell Helpers ────────────────────────────────────────────────────────────
function isMMRL() {
  return navigator.userAgent.includes("com.dergoogler.mmrl");
}

function runShell(cmd) {
  return new Promise((resolve, reject) => {
    if (typeof ksu === "object" && typeof ksu.exec === "function") {
      const cbName = `cb_${Date.now()}`;
      window[cbName] = (code, stdout, stderr) => {
        delete window[cbName];
        code === 0 ? resolve(stdout) : reject(stderr || "Shell error");
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

// ─── Custom Package Helpers ───────────────────────────────────────────────────
function getCustomPackage() {
  return document.getElementById("custom-package-input").value.trim();
}

// ─── Reset Props ──────────────────────────────────────────────────────────────
function getPropsFilter() {
  return document.getElementById("props-filter-input").value.trim();
}

async function viewProps() {
  const filter = getPropsFilter();
  if (!filter) { popup("Enter a filter pattern first"); return; }

  popup("Fetching props...");
  clearOutput();
  logOutput(`[*] Looking for props matching: ${filter}`);

  const cmd = `getprop | grep -E "${filter}" | sed -E 's/^\\[(.*)\\]:.*/\\1/'`;
  try {
    const out = await runShell(cmd);
    if (out.trim()) {
      logOutput(out);
      logOutput(`\n[+] Found ${out.trim().split("\n").length} prop(s)`);
    } else {
      logOutput("[*] No matching props found");
    }
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

  const listCmd = `getprop | grep -E "${filter}" | sed -E 's/^\\[(.*)\\]:.*/\\1/'`;
  let props = [];
  try {
    const out = await runShell(listCmd);
    props = out.trim() ? out.trim().split("\n") : [];
  } catch (e) {
    logOutput(`[!] Error listing props: ${e}`);
    return;
  }

  if (props.length === 0) {
    logOutput("[*] No matching props found — nothing to reset");
    return;
  }

  logOutput(`[*] Found ${props.length} prop(s), resetting...`);

  const resetCmd = `
    getprop | grep -E "${filter}" | sed -E 's/^\\[(.*)\\]:.*/\\1/' | while IFS= read -r prop; do
      resetprop -p -d "$prop" && echo "[+] Reset: $prop" || echo "[!] Failed: $prop"
    done
  `;
  try {
    const out = await runShell(resetCmd);
    logOutput(out || "[+] Done");
  } catch (e) {
    logOutput(`[!] Error: ${e}`);
  }
}

// ─── Settings Panel ───────────────────────────────────────────────────────────
function initSettings() {
  const btn     = document.getElementById("settings-btn");
  const panel   = document.getElementById("settings-panel");
  const overlay = document.getElementById("settings-overlay");
  const close   = document.getElementById("settings-close");

  function openPanel() {
    panel.classList.add("open");
    overlay.classList.add("open");
    btn.classList.add("open");
  }
  function closePanel() {
    panel.classList.remove("open");
    overlay.classList.remove("open");
    btn.classList.remove("open");
  }

  btn.addEventListener("click", () =>
    panel.classList.contains("open") ? closePanel() : openPanel()
  );
  close.addEventListener("click", closePanel);
  overlay.addEventListener("click", closePanel);
}

// ─── Quick Action ─────────────────────────────────────────────────────────────
async function runAllAction() {
  const btn = document.getElementById("action-btn");
  btn.disabled = true;
  btn.textContent = "Running...";

  popup("Running all root-hide scripts...");
  clearOutput();
  logOutput("[*] Quick Action started...\n");

  const steps = [
    { label: "Security Patch",       path: SECURITY_PATCH },
    { label: "Boot Hash",            path: BOOT_HASH      },
    { label: "Clear Detection Traces", path: CLEAR_TRACES },
    { label: "Fix TEE",              path: TEE            },
  ];

  // Run scripts sequentially
  for (const step of steps) {
    logOutput(`\n[>] ${step.label}...`);
    try {
      const out = await runShell(`sh ${step.path}`);
      logOutput(out || "[+] Done");
    } catch (e) {
      logOutput(`[!] Error in ${step.label}: ${e}`);
    }
  }

  // Reset pixel props
  logOutput("\n[>] Resetting pixel props...");
  const resetCmd = `
    getprop | grep -iE "pixel" | sed -E 's/^\\[(.*)\\]:.*/\\1/' | while IFS= read -r prop; do
      resetprop -p -d "$prop" && echo "[+] Reset: $prop" || echo "[!] Failed: $prop"
    done
  `;
  try {
    const out = await runShell(resetCmd);
    if (out.trim()) {
      logOutput(out);
    } else {
      logOutput("[*] No pixel props found");
    }
  } catch (e) {
    logOutput(`[!] Error resetting props: ${e}`);
  }

  logOutput("\n[✓] Quick Action complete");
  popup("Done!");

  btn.disabled = false;
  btn.textContent = "Run All";
}


function forceRepaint() {
  // Force the browser to flush and repaint all GPU layers
  document.body.style.display = "none";
  void document.body.offsetHeight;
  document.body.style.display = "";
}

function initTheme() {
  const toggle = document.getElementById("theme-toggle");
  const saved  = localStorage.getItem("theme");

  if (saved === "dark") {
    document.documentElement.classList.add("dark");
    toggle.checked = true;
  } else {
    document.documentElement.classList.remove("dark");
    toggle.checked = false;
  }

  toggle.addEventListener("change", () => {
    if (toggle.checked) {
      document.documentElement.classList.add("dark");
      localStorage.setItem("theme", "dark");
    } else {
      document.documentElement.classList.remove("dark");
      localStorage.setItem("theme", "light");
    }
    forceRepaint();
  });
}

// ─── Action Toggle ────────────────────────────────────────────────────────────
function initActionToggle() {
  const toggle = document.getElementById("action-toggle");
  const card   = document.getElementById("action-card");
  const saved  = localStorage.getItem("showAction");

  if (saved === "1") {
    card.style.display = "";
    toggle.checked = true;
  }

  toggle.addEventListener("change", () => {
    if (toggle.checked) {
      card.style.display = "";
      localStorage.setItem("showAction", "1");
    } else {
      card.style.display = "none";
      localStorage.setItem("showAction", "0");
    }
  });
}

// ─── Init ─────────────────────────────────────────────────────────────────────
document.addEventListener("DOMContentLoaded", () => {
  getModuleName();
  initTheme();
  initSettings();
  initActionToggle();

  // Main Controls
  document.getElementById("update-btn")
    .addEventListener("click", () => executeScript(UPDATE, "Updating target list"));
  document.getElementById("clear-btn")
    .addEventListener("click", () => executeScript(CLEAR, "Clearing target list"));
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
    pkg ? executeScriptWithArg(ADD_CUSTOM, pkg, "Adding custom package")
        : popup("Please enter a package name");
  });
  document.getElementById("remove-custom-btn").addEventListener("click", () => {
    const pkg = getCustomPackage();
    pkg ? executeScriptWithArg(REMOVE_CUSTOM, pkg, "Removing custom package")
        : popup("Please enter a package name");
  });
  document.getElementById("view-custom-btn")
    .addEventListener("click", viewCustomList);

  // Security Tools
  document.getElementById("security-patch-btn")
    .addEventListener("click", () => executeScript(SECURITY_PATCH, "Running security patch"));
  document.getElementById("boot-hash-btn")
    .addEventListener("click", () => executeScript(BOOT_HASH, "Running boot hash"));
  document.getElementById("clear-traces-btn")
    .addEventListener("click", () => executeScript(CLEAR_TRACES, "Clearing detection traces"));
  document.getElementById("fix-tee-btn")
    .addEventListener("click", () => executeScript(TEE, "Fixing TEE"));

  // Quick Action
  document.getElementById("action-btn")
    .addEventListener("click", runAllAction);

  // Reset Props
  document.getElementById("view-props-btn")
    .addEventListener("click", viewProps);
  document.getElementById("reset-props-btn")
    .addEventListener("click", resetProps);

  // Terminal
  document.getElementById("clear-output")
    .addEventListener("click", clearOutput);
});
