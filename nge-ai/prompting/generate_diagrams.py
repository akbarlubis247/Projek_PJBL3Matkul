import os
import matplotlib.pyplot as plt
import matplotlib.patches as patches

OUT_DIR = os.path.join(os.path.dirname(__file__), 'doc_assets')
os.makedirs(OUT_DIR, exist_ok=True)

plt.rcParams['font.family'] = 'DejaVu Sans'
plt.rcParams['text.color'] = '#000000'
plt.rcParams['axes.edgecolor'] = '#000000'

def draw_usecase():
    fig, ax = plt.subplots(figsize=(13, 10), dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    # System Boundary
    rect = patches.FancyBboxPatch((24, 3), 52, 94, boxstyle="round,pad=0.5", 
                                  edgecolor="#1E293B", facecolor="#FFFFFF", linewidth=2)
    ax.add_patch(rect)
    ax.text(50, 94.5, "Sistem Campus Lapor (Web & Mobile)", ha='center', va='center', 
            fontsize=13, fontweight='bold', color="#0F172A")

    # Actors
    def draw_actor(x, y, name):
        # Head
        circle = patches.Circle((x, y + 2.5), 1.8, edgecolor="#000000", facecolor="#FFFFFF", linewidth=1.8)
        ax.add_patch(circle)
        # Body
        ax.plot([x, x], [y + 0.7, y - 3.5], color="#000000", linewidth=1.8)
        # Arms
        ax.plot([x - 2.5, x + 2.5], [y - 0.8, y - 0.8], color="#000000", linewidth=1.8)
        # Legs
        ax.plot([x, x - 2], [y - 3.5, y - 7], color="#000000", linewidth=1.8)
        ax.plot([x, x + 2], [y - 3.5, y - 7], color="#000000", linewidth=1.8)
        # Label
        ax.text(x, y - 9, name, ha='center', va='top', fontsize=9.5, fontweight='bold')

    draw_actor(11, 62, "Civitas\nAkademika\n(Mobile)")
    draw_actor(89, 75, "Admin\nKampus\n(Web)")
    draw_actor(89, 28, "Superadmin\n(Web)")

    # Use cases: (x, y, label, width, height)
    usecases = [
        # Civitas
        (50, 89, "UC01: Registrasi Akun Civitas", 34, 4.2),
        (50, 83, "UC02: Login & Autentikasi Sistem", 34, 4.2),
        (50, 77, "UC03: Membuat Laporan Barang Hilang / Temuan", 36, 4.2),
        (50, 71, "UC04: Membuat Laporan Fasilitas Rusak", 34, 4.2),
        (50, 65, "UC05: Tracking Riwayat & Status Laporan", 35, 4.2),
        (50, 59, "UC06: Berkirim Pesan / Chat Real-time", 34, 4.2),
        (50, 53, "UC07: Mengelola Profil Pengguna", 32, 4.2),
        # Admin
        (50, 46, "UC08: Verifikasi Persetujuan Akun Civitas", 35, 4.2),
        (50, 40, "UC09: Kelola Status Laporan Barang", 33, 4.2),
        (50, 34, "UC10: Kelola & Tindak Lanjut Fasilitas", 34, 4.2),
        (50, 28, "UC11: Manajemen Gedung & Lokasi Kampus", 35, 4.2),
        (50, 22, "UC12: Ekspor Laporan (PDF & Excel)", 32, 4.2),
        # Superadmin
        (50, 15, "UC13: Seleksi & Verifikasi Pendaftaran Admin", 36, 4.2),
        (50, 8,  "UC14: Monitoring Data Kampus & Admin Aktif", 36, 4.2),
    ]

    for (ux, uy, txt, w, h) in usecases:
        ellipse = patches.Ellipse((ux, uy), w, h, edgecolor="#2563EB", facecolor="#F8FAFC", linewidth=1.5)
        ax.add_patch(ellipse)
        ax.text(ux, uy, txt, ha='center', va='center', fontsize=8.5, color="#1E293B")

    # Lines from Civitas (x=13, y=55)
    civ_lines = [89, 83, 77, 71, 65, 59, 53]
    for target_y in civ_lines:
        ax.plot([14.5, 33], [58, target_y], color="#475569", linestyle="-", linewidth=1.1)

    # Lines from Admin (x=87, y=70)
    admin_lines = [83, 59, 46, 40, 34, 28, 22]
    for target_y in admin_lines:
        ax.plot([85.5, 67], [70, target_y], color="#475569", linestyle="-", linewidth=1.1)

    # Lines from Superadmin (x=87, y=24)
    super_lines = [83, 15, 8]
    for target_y in super_lines:
        ax.plot([85.5, 68], [24, target_y], color="#475569", linestyle="-", linewidth=1.1)

    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, 'diagram_usecase.png'), bbox_inches='tight', dpi=300)
    plt.close()
    print("Use Case Diagram saved.")

def draw_activity_barang():
    fig, ax = plt.subplots(figsize=(11, 8.5), dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    # Title
    ax.text(50, 97, "Activity Diagram: Pelaporan Barang Hilang & Klaim Penemuan", 
            ha='center', va='center', fontsize=12, fontweight='bold')

    # Swimlanes
    ax.plot([33.3, 33.3], [5, 93], color="#000000", linewidth=1.2)
    ax.plot([66.6, 66.6], [5, 93], color="#000000", linewidth=1.2)
    ax.plot([2, 98], [88, 88], color="#000000", linewidth=1.5)
    ax.plot([2, 98], [5, 5], color="#000000", linewidth=1.2)
    ax.plot([2, 2], [5, 93], color="#000000", linewidth=1.2)
    ax.plot([98, 98], [5, 93], color="#000000", linewidth=1.2)
    ax.plot([2, 98], [93, 93], color="#000000", linewidth=1.2)

    ax.text(17.6, 90.5, "Civitas Akademika (Mobile)", ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(50, 90.5, "Sistem Campus Lapor", ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(82.3, 90.5, "Admin Kampus (Web)", ha='center', va='center', fontsize=10, fontweight='bold')

    def act_box(x, y, w, h, text):
        box = patches.FancyBboxPatch((x - w/2, y - h/2), w, h, boxstyle="round,pad=0.3",
                                     edgecolor="#000000", facecolor="#FFFFFF", linewidth=1.2)
        ax.add_patch(box)
        ax.text(x, y, text, ha='center', va='center', fontsize=8.2, multialignment='center')

    # Initial node
    start = patches.Circle((17.6, 83), 1.6, edgecolor="#000000", facecolor="#000000")
    ax.add_patch(start)

    # Step 1: Input laporan
    act_box(17.6, 73, 27, 6.5, "Mengisi Form Laporan Barang\n(Nama, Lokasi, Deskripsi, Foto)")
    ax.annotate('', xy=(17.6, 76.5), xytext=(17.6, 81.2),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 2: Sistem menyimpan
    act_box(50, 73, 27, 6.5, "Validasi Input & Menyimpan\nLaporan ke MongoDB (Status: Hilang)")
    ax.annotate('', xy=(36.5, 73), xytext=(31.1, 73),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 3: Admin melihat laporan
    act_box(82.3, 73, 26, 6.5, "Melihat Laporan Masuk pada\nMenu Barang Hilang")
    ax.annotate('', xy=(69.3, 73), xytext=(63.5, 73),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 4: Admin update status
    act_box(82.3, 56, 26, 7, "Menerima Info Temuan &\nMengubah Status jadi 'Ditemukan'")
    ax.annotate('', xy=(82.3, 59.5), xytext=(82.3, 69.5),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 5: Sistem notifikasi
    act_box(50, 56, 27, 7, "Memperbarui Data Koleksi &\nKirim Notifikasi ke Pelapor")
    ax.annotate('', xy=(63.5, 56), xytext=(69.3, 56),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 6: Civitas klaim
    act_box(17.6, 56, 27, 7, "Menerima Notifikasi &\nKonfirmasi Klaim Barang ke Pos Admin")
    ax.annotate('', xy=(31.1, 56), xytext=(36.5, 56),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 7: Admin verifikasi serah terima
    act_box(82.3, 38, 26, 7.5, "Memverifikasi Identitas Pemilik\ndan Menyerahkan Barang")
    ax.annotate('', xy=(82.3, 42), xytext=(31.1, 53),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2, connectionstyle="arc3,rad=-0.15"))

    # Step 8: Tandai barang diambil
    act_box(82.3, 24, 26, 6.5, "Menandai Laporan:\n'Barang Sudah Diambil'")
    ax.annotate('', xy=(82.3, 27.5), xytext=(82.3, 34),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 9: Sistem arsip
    act_box(50, 24, 27, 6.5, "Menyimpan Status Akhir\ndan Menutup Tiket Laporan")
    ax.annotate('', xy=(63.5, 24), xytext=(69.3, 24),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # End node
    end_outer = patches.Circle((50, 12), 2.2, edgecolor="#000000", facecolor="#FFFFFF", linewidth=1.2)
    end_inner = patches.Circle((50, 12), 1.5, edgecolor="#000000", facecolor="#000000")
    ax.add_patch(end_outer)
    ax.add_patch(end_inner)
    ax.annotate('', xy=(50, 14.5), xytext=(50, 20.5),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, 'diagram_activity_barang.png'), bbox_inches='tight', dpi=300)
    plt.close()
    print("Activity Diagram Barang saved.")

def draw_activity_fasilitas():
    fig, ax = plt.subplots(figsize=(11, 8.5), dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    ax.text(50, 97, "Activity Diagram: Pelaporan Fasilitas Rusak & Perbaikan", 
            ha='center', va='center', fontsize=12, fontweight='bold')

    # Swimlanes
    ax.plot([33.3, 33.3], [5, 93], color="#000000", linewidth=1.2)
    ax.plot([66.6, 66.6], [5, 93], color="#000000", linewidth=1.2)
    ax.plot([2, 98], [88, 88], color="#000000", linewidth=1.5)
    ax.plot([2, 98], [5, 5], color="#000000", linewidth=1.2)
    ax.plot([2, 2], [5, 93], color="#000000", linewidth=1.2)
    ax.plot([98, 98], [5, 93], color="#000000", linewidth=1.2)
    ax.plot([2, 98], [93, 93], color="#000000", linewidth=1.2)

    ax.text(17.6, 90.5, "Civitas Akademika (Mobile)", ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(50, 90.5, "Sistem Campus Lapor", ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(82.3, 90.5, "Admin Kampus (Web)", ha='center', va='center', fontsize=10, fontweight='bold')

    def act_box(x, y, w, h, text):
        box = patches.FancyBboxPatch((x - w/2, y - h/2), w, h, boxstyle="round,pad=0.3",
                                     edgecolor="#000000", facecolor="#FFFFFF", linewidth=1.2)
        ax.add_patch(box)
        ax.text(x, y, text, ha='center', va='center', fontsize=8.2, multialignment='center')

    # Initial node
    start = patches.Circle((17.6, 83), 1.6, edgecolor="#000000", facecolor="#000000")
    ax.add_patch(start)

    # Step 1: Input laporan fasilitas
    act_box(17.6, 73, 27, 6.5, "Input Kerusakan Fasilitas\n(Nama Fasilitas, Gedung, Foto Bukti)")
    ax.annotate('', xy=(17.6, 76.5), xytext=(17.6, 81.2),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 2: Sistem simpan
    act_box(50, 73, 27, 6.5, "Validasi Data & Simpan Laporan\n(Status: Menunggu Perbaikan)")
    ax.annotate('', xy=(36.5, 73), xytext=(31.1, 73),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 3: Admin review
    act_box(82.3, 73, 26, 6.5, "Melihat Daftar Fasilitas Rusak\npada Dashboard Admin")
    ax.annotate('', xy=(69.3, 73), xytext=(63.5, 73),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 4: Admin koordinasi teknisi
    act_box(82.3, 55, 26, 7.5, "Menugaskan Teknisi / Petugas\nSarpras untuk Pengecekan")
    ax.annotate('', xy=(82.3, 59), xytext=(82.3, 69.5),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 5: Teknisi selesai & Admin tandai
    act_box(82.3, 38, 26, 7.5, "Menerima Laporan Selesai &\nKlik 'Tandai Selesai Diperbaiki'")
    ax.annotate('', xy=(82.3, 42), xytext=(82.3, 51),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 6: Sistem update status & pindahkan ke riwayat
    act_box(50, 38, 27, 7.5, "Update Status: 'Diperbaiki',\nCatat Tanggal Selesai & Notifikasi")
    ax.annotate('', xy=(63.5, 38), xytext=(69.3, 38),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 7: Civitas melihat status
    act_box(17.6, 38, 27, 7.5, "Melihat Status Perbaikan Selesai\npada Tab Riwayat Mobile")
    ax.annotate('', xy=(31.1, 38), xytext=(36.5, 38),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 8: End node
    end_outer = patches.Circle((17.6, 20), 2.2, edgecolor="#000000", facecolor="#FFFFFF", linewidth=1.2)
    end_inner = patches.Circle((17.6, 20), 1.5, edgecolor="#000000", facecolor="#000000")
    ax.add_patch(end_outer)
    ax.add_patch(end_inner)
    ax.annotate('', xy=(17.6, 22.5), xytext=(17.6, 34),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, 'diagram_activity_fasilitas.png'), bbox_inches='tight', dpi=300)
    plt.close()
    print("Activity Diagram Fasilitas saved.")

def draw_activity_seleksi_admin():
    fig, ax = plt.subplots(figsize=(11, 8.5), dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    ax.text(50, 97, "Activity Diagram: Pendaftaran & Seleksi Admin Kampus", 
            ha='center', va='center', fontsize=12, fontweight='bold')

    # Swimlanes
    ax.plot([33.3, 33.3], [5, 93], color="#000000", linewidth=1.2)
    ax.plot([66.6, 66.6], [5, 93], color="#000000", linewidth=1.2)
    ax.plot([2, 98], [88, 88], color="#000000", linewidth=1.5)
    ax.plot([2, 98], [5, 5], color="#000000", linewidth=1.2)
    ax.plot([2, 2], [5, 93], color="#000000", linewidth=1.2)
    ax.plot([98, 98], [5, 93], color="#000000", linewidth=1.2)
    ax.plot([2, 98], [93, 93], color="#000000", linewidth=1.2)

    ax.text(17.6, 90.5, "Calon Admin Kampus", ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(50, 90.5, "Sistem Campus Lapor", ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(82.3, 90.5, "Superadmin (Web)", ha='center', va='center', fontsize=10, fontweight='bold')

    def act_box(x, y, w, h, text):
        box = patches.FancyBboxPatch((x - w/2, y - h/2), w, h, boxstyle="round,pad=0.3",
                                     edgecolor="#000000", facecolor="#FFFFFF", linewidth=1.2)
        ax.add_patch(box)
        ax.text(x, y, text, ha='center', va='center', fontsize=8.2, multialignment='center')

    # Initial node
    start = patches.Circle((17.6, 83), 1.6, edgecolor="#000000", facecolor="#000000")
    ax.add_patch(start)

    # Step 1: Calon admin daftar
    act_box(17.6, 73, 27, 6.5, "Mengisi Form Pendaftaran Admin\n& Unggah Dokumen SK/Surat Tugas")
    ax.annotate('', xy=(17.6, 76.5), xytext=(17.6, 81.2),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 2: Sistem simpan pendaftaran
    act_box(50, 73, 27, 6.5, "Menyimpan Data Pendaftaran ke\nKoleksi admin_applications (Pending)")
    ax.annotate('', xy=(36.5, 73), xytext=(31.1, 73),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 3: Superadmin review
    act_box(82.3, 73, 26, 6.5, "Membuka Menu Seleksi Admin &\nMemeriksa Dokumen Legalitas")
    ax.annotate('', xy=(69.3, 73), xytext=(63.5, 73),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Step 4: Decision
    # Diamond decision
    diamond = patches.Polygon([[82.3, 58], [88, 53], [82.3, 48], [76.6, 53]], 
                              edgecolor="#000000", facecolor="#FFFFFF", linewidth=1.2)
    ax.add_patch(diamond)
    ax.text(82.3, 53, "Disetujui?", ha='center', va='center', fontsize=7.8, fontweight='bold')
    ax.annotate('', xy=(82.3, 58), xytext=(82.3, 69.5),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Path Disetujui (Ya)
    ax.text(73.5, 54, "[Ya]", fontsize=8)
    act_box(50, 53, 27, 6.5, "Update Status 'approved' &\nBuat Akun Login di Koleksi users")
    ax.annotate('', xy=(63.5, 53), xytext=(76.6, 53),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # Path Ditolak (Tidak)
    ax.text(89, 54, "[Tidak]", fontsize=8)
    act_box(82.3, 36, 26, 6.5, "Ubah Status jadi 'rejected'\n& Berikan Alasan Penolakan")
    ax.annotate('', xy=(82.3, 39.5), xytext=(88, 53),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2, connectionstyle="arc3,rad=-0.2"))

    # Calon admin login jika approved
    act_box(17.6, 53, 27, 6.5, "Admin Menerima Akun Aktif &\nDapat Login ke Dashboard Kampus")
    ax.annotate('', xy=(31.1, 53), xytext=(36.5, 53),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))

    # End node
    end_outer = patches.Circle((50, 20), 2.2, edgecolor="#000000", facecolor="#FFFFFF", linewidth=1.2)
    end_inner = patches.Circle((50, 20), 1.5, edgecolor="#000000", facecolor="#000000")
    ax.add_patch(end_outer)
    ax.add_patch(end_inner)
    ax.annotate('', xy=(50, 22.5), xytext=(50, 49.5),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))
    ax.annotate('', xy=(52.5, 20), xytext=(69.3, 36),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2, connectionstyle="arc3,rad=0.2"))

    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, 'diagram_activity_seleksi_admin.png'), bbox_inches='tight', dpi=300)
    plt.close()
    print("Activity Diagram Seleksi Admin saved.")

def draw_database_schema():
    fig, ax = plt.subplots(figsize=(14, 10), dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    ax.text(50, 97.5, "Arsitektur Database NoSQL MongoDB: Koleksi & Schema Kampus Lapor", 
            ha='center', va='center', fontsize=12.5, fontweight='bold')

    def draw_table(x, y, w, h, title, fields):
        # Header box
        header = patches.Rectangle((x, y + h - 4.5), w, 4.5, edgecolor="#000000", facecolor="#E2E8F0", linewidth=1.2)
        ax.add_patch(header)
        ax.text(x + w/2, y + h - 2.25, title, ha='center', va='center', fontsize=9.5, fontweight='bold')
        # Body box
        body = patches.Rectangle((x, y), w, h - 4.5, edgecolor="#000000", facecolor="#FFFFFF", linewidth=1.2)
        ax.add_patch(body)
        # Fields
        line_y = y + h - 7
        for f, t in fields:
            ax.text(x + 1.5, line_y, f, ha='left', va='center', fontsize=8, family='monospace', fontweight='bold' if '_id' in f or 'username' in f else 'normal')
            ax.text(x + w - 1.5, line_y, t, ha='right', va='center', fontsize=7.8, family='monospace', color="#475569")
            line_y -= 3.1

    # 1. users
    draw_table(3, 56, 27, 36, "users (Koleksi Pengguna)", [
        ("_id", "ObjectId (PK)"),
        ("username", "String (Unique)"),
        ("password", "String (Bcrypt)"),
        ("nama_lengkap", "String"),
        ("email", "String"),
        ("nim", "String"),
        ("role", "String (admin/civ/sup)"),
        ("kode_kampus", "String"),
        ("nama_kampus", "String"),
        ("status_persetujuan", "String"),
        ("created_at", "Date"),
    ])

    # 2. campus_reports
    draw_table(36, 50, 31, 42, "campus_reports (Laporan)", [
        ("_id", "ObjectId (PK)"),
        ("kode_kampus", "String (Ref)"),
        ("jenis_laporan", "String (barang/fas)"),
        ("tipe_sub", "String (hilang/temuan)"),
        ("judul", "String"),
        ("lokasi_kejadian", "String"),
        ("deskripsi", "String"),
        ("foto_path", "String"),
        ("pelapor_username", "String (Ref)"),
        ("pelapor_nim", "String"),
        ("status", "String"),
        ("catatan_admin", "String"),
        ("tanggal_diperbaiki", "Date"),
        ("created_at", "Date"),
    ])

    # 3. campus_locations
    draw_table(73, 70, 24, 22, "campus_locations", [
        ("_id", "ObjectId (PK)"),
        ("kode_kampus", "String (Ref)"),
        ("nama_lokasi", "String"),
        ("deskripsi", "String"),
        ("created_at", "Date"),
    ])

    # 4. admin_applications
    draw_table(73, 38, 24, 28, "admin_applications", [
        ("_id", "ObjectId (PK)"),
        ("nama_lengkap", "String"),
        ("email", "String"),
        ("nama_kampus", "String"),
        ("dokumen_sk_path", "String"),
        ("status_seleksi", "String"),
        ("alasan_penolakan", "String"),
        ("created_at", "Date"),
    ])

    # 5. chat_threads
    draw_table(3, 10, 27, 34, "chat_threads (Sesi Chat)", [
        ("_id", "ObjectId (PK)"),
        ("participant_1", "String (Ref user)"),
        ("participant_2", "String (Ref user)"),
        ("kode_kampus", "String (Ref)"),
        ("last_message", "String"),
        ("last_sent_at", "Date"),
        ("unread_count_p1", "Integer"),
        ("unread_count_p2", "Integer"),
        ("created_at", "Date"),
    ])

    # 6. messages
    draw_table(36, 8, 31, 34, "messages (Pesan Obrolan)", [
        ("_id", "ObjectId (PK)"),
        ("thread_id", "ObjectId (Ref)"),
        ("sender_username", "String (Ref)"),
        ("receiver_username", "String (Ref)"),
        ("message_content", "String"),
        ("lampiran_path", "String"),
        ("is_read", "Boolean"),
        ("created_at", "Date"),
    ])

    # 7. notifications
    draw_table(73, 6, 24, 28, "notifications", [
        ("_id", "ObjectId (PK)"),
        ("target_username", "String (Ref)"),
        ("judul_notifikasi", "String"),
        ("pesan", "String"),
        ("is_read", "Boolean"),
        ("created_at", "Date"),
    ])

    # Connectors
    # users -> campus_reports
    ax.annotate('', xy=(36, 73), xytext=(30, 73),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))
    ax.text(33, 74.5, "1 : N", ha='center', fontsize=8, fontweight='bold')

    # campus_locations -> campus_reports
    ax.annotate('', xy=(67, 78), xytext=(73, 78),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))
    ax.text(70, 79.5, "1 : N", ha='center', fontsize=8, fontweight='bold')

    # users -> chat_threads
    ax.annotate('', xy=(16.5, 44), xytext=(16.5, 56),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))
    ax.text(19, 50, "1 : N", ha='center', fontsize=8, fontweight='bold')

    # chat_threads -> messages
    ax.annotate('', xy=(36, 24), xytext=(30, 24),
                arrowprops=dict(facecolor='black', arrowstyle='->', lw=1.2))
    ax.text(33, 25.5, "1 : N", ha='center', fontsize=8, fontweight='bold')

    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, 'diagram_database_schema.png'), bbox_inches='tight', dpi=300)
    plt.close()
    print("Database Schema Diagram saved.")

if __name__ == '__main__':
    draw_usecase()
    draw_activity_barang()
    draw_activity_fasilitas()
    draw_activity_seleksi_admin()
    draw_database_schema()
