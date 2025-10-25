const menuToggle = document.getElementById("menuToggle");
const navLinks = document.querySelector(".nav-links");

if (menuToggle && navLinks) {
  menuToggle.addEventListener("click", () => {
    navLinks.classList.toggle("active");
  });
}

/* Wallet panel akışı */
const connectBtn = document.getElementById("connectBtn");
const userArea = document.getElementById("userArea");
const userMenu = document.getElementById("userMenu");
const addrShort = document.getElementById("addrShort");
const addrFull = document.getElementById("addrFull");

let isConnected = false;
// Demo adres. Gerçekte cüzdandan dönen adresi yaz.
let currentAddress = "0x7b1f3c8a4E12B9A2cC40C2A5Bf0F1d9A0dE8C001";

function shortAddr(addr) {
  if (!addr) return "0x…";
  return addr.slice(0, 6) + "…" + addr.slice(-4);
}

function setConnectedUI(address) {
  addrShort.textContent = shortAddr(address);
  addrFull.textContent = address;
  connectBtn.classList.add("hidden");
  userArea.classList.remove("hidden");
  isConnected = true;
}

function setDisconnectedUI() {
  userArea.classList.add("hidden");
  userArea.classList.remove("open");
  userMenu.setAttribute("aria-hidden", "true");
  connectBtn.classList.remove("hidden");
  isConnected = false;
}

// Connect akışı
connectBtn.addEventListener("click", async () => {
  // Burada gerçek cüzdan bağlantısını yaparsın.
  // Örn: const address = await suiWallet.connect();
  // Demo için currentAddress kullanıyorum:
  setConnectedUI(currentAddress);
});

// Paneli aç kapa
userArea.addEventListener("click", (e) => {
  e.stopPropagation();
  const willOpen = !userArea.classList.contains("open");
  document.querySelectorAll(".user-area.open").forEach(el => {
    el.classList.remove("open");
    el.querySelector(".user-menu")?.setAttribute("aria-hidden", "true");
  });
  if (willOpen) {
    userArea.classList.add("open");
    userMenu.setAttribute("aria-hidden", "false");
  }
});

// Dışarı tıklayınca kapat
document.addEventListener("click", () => {
  if (userArea.classList.contains("open")) {
    userArea.classList.remove("open");
    userMenu.setAttribute("aria-hidden", "true");
  }
});

// Menü aksiyonları
userMenu.addEventListener("click", (e) => {
  const item = e.target.closest(".menu-item");
  if (!item) return;
  const action = item.dataset.action;

  switch (action) {
    case "profile":
      // Profil sayfasına yönlendir
      window.location.hash = "#profile";
      break;
    case "activity":
      // Activity modal ya da sayfa
      window.location.hash = "#activity";
      break;
    case "settings":
      window.location.hash = "#settings";
      break;
    case "support":
      window.location.hash = "#help-center";
      break;
    case "copy":
      navigator.clipboard.writeText(addrFull.textContent).then(() => {
        item.textContent = "Copied";
        setTimeout(() => (item.textContent = "Copy Address"), 1200);
      });
      break;
    case "logout":
      setDisconnectedUI();
      break;
  }
});