# DPDK Tracing with LTTng

This project demonstrates how to build DPDK with function-level tracing enabled using `-finstrument-functions`, set up hugepages, and trace function calls with **LTTng**.

---

## 1️⃣ Build DPDK with `-finstrument-functions`

```bash
git clone https://github.com/DPDK/dpdk.git
cd dpdk
sudo meson setup builddir --buildtype=debug -Dexamples=all -Dc_args='-finstrument-functions'
sudo ninja -C builddir
2️⃣ Mount HugePages
bash
Copy
Edit
sudo mkdir -p /mnt/huge
echo 1024 | sudo tee /proc/sys/vm/nr_hugepages
sudo mount -t hugetlbfs nodev /mnt/huge
3️⃣ Run LTTng and Trace Functions
bash
Copy
Edit
sudo apt install lttng-tools lttng-modules-dkms liblttng-ust-dev

lttng create dpdk-trace
lttng enable-event -u -a
lttng start

./builddir/examples/dpdk-l2fwd &

sleep 5

lttng stop
lttng view
📌 Notes
Traces will be stored under .lttng/. Use tools like Trace Compass to analyze them.

yaml
Copy
Edit

---

اگر خواستی، فایل نهایی `README.md` رو همینجا کامل برات بسازم تا فقط copy/paste کنی. بگم بنویسم؟






You said:
اره فایل کاملشو بنویس
ChatGPT said:
حتماً، در ادامه یک فایل کامل README.md برای پروژه‌ی DPDK + Tracing با LTTng برات نوشتم. فقط کافیه اونو در پروژه‌ات ذخیره کنی به‌نام README.md.

markdown
Copy
Edit
# DPDK Tracing with LTTng

This project demonstrates how to build [DPDK](https://www.dpdk.org/) with function-level tracing using `-finstrument-functions`, mount hugepages, and trace execution using [LTTng](https://lttng.org/).

---

## 📦 Prerequisites

- Ubuntu 20.04 or later
- Git
- Meson and Ninja
- GCC or Clang
- LTTng tools and userspace tracing support

Install essentials:

```bash
sudo apt update
sudo apt install git build-essential meson ninja-build \
lttng-tools lttng-modules-dkms liblttng-ust-dev \
python3-pyelftools
1️⃣ Build DPDK with -finstrument-functions
Clone and build DPDK with tracing flags enabled:

bash
Copy
Edit
git clone https://github.com/DPDK/dpdk.git
cd dpdk

sudo meson setup builddir \
  --buildtype=debug \
  -Dexamples=all \
  -Dc_args='-finstrument-functions'

sudo ninja -C builddir
🔧 The -finstrument-functions flag enables automatic calls to __cyg_profile_func_enter and __cyg_profile_func_exit at every function entry/exit — allowing tracing via tools like LTTng.

2️⃣ Mount HugePages
DPDK requires hugepages for high-speed memory allocation:

bash
Copy
Edit
# Allocate 1024 hugepages (2MB each)
echo 1024 | sudo tee /proc/sys/vm/nr_hugepages

# Mount hugepage filesystem
sudo mkdir -p /mnt/huge
sudo mount -t hugetlbfs nodev /mnt/huge
💡 You can check allocation using: cat /proc/meminfo | grep HugePages

3️⃣ Trace Function Calls with LTTng
🔹 Create and Start LTTng Session
bash
Copy
Edit
lttng create dpdk-trace
lttng enable-event -u -a   # Enable all userspace events
lttng start
🔹 Run Your DPDK Application
bash
Copy
Edit
./builddir/examples/dpdk-l2fwd &
sleep 5  # Wait for a few seconds of execution
🔹 Stop and View Trace
bash
Copy
Edit
lttng stop
lttng view
📁 Traces are saved under ~/.lttng/trace/ by default.

4️⃣ (Optional) Unmount HugePages
bash
Copy
Edit
sudo umount /mnt/huge
📊 Visualizing Traces
You can analyze the generated trace using Trace Compass:

bash
Copy
Edit
sudo snap install trace-compass
Then open the trace folder and explore function-level execution.

📁 Project Structure
bash
Copy
Edit
dpdk-tracing/
├── dpdk/                   # Cloned DPDK source
├── builddir/               # Build output (Meson/Ninja)
├── README.md               # This documentation
└── traces/                 # (Optional) LTTng trace output
🧪 Automating Setup
You can optionally create a trace_dpdk.sh script to automate the process of setup, mount, trace, and run. See README for step-by-step commands.

📬 Contact
For issues or improvements, feel free to open an issue or pull request.
