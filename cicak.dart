import 'dart:io';
import 'dart:math';

// Fungsi untuk membersihkan layar terminal
void bersihkanLayar() {
  print("\x1B[2J\x1B[0;0H");
}

// Fungsi untuk jeda dalam milidetik
Future<void> jeda(int milidetik) async {
  await Future.delayed(Duration(milliseconds: milidetik));
}

// Fungsi untuk menghasilkan angka acak antara min dan max (inklusif)
int acak(int min, int max) {
  return min + Random().nextInt(max - min);
}

// Fungsi untuk mendapatkan ukuran terminal
List<int> ukuranLayar() {
  return [stdout.terminalColumns, stdout.terminalLines];
}

// Fungsi untuk memindahkan kursor ke baris dan kolom tertentu
void pindahKe(int baris, int kolom) {
  stdout.write('\x1B[${baris};${kolom}H');
}

// Fungsi untuk menaruh makanan di posisi acak
void taruhMakanan() {
  makanan = Point(acak(3, lebar), acak(3, tinggi));
  while (kadalleo.contains(makanan)) {
    makanan = Point(acak(3, lebar), acak(3, tinggi));
  }
}

// Lebar dan tinggi grid disesuaikan dengan ukuran terminal dengan margin 3 dari tepi
int lebar = ukuranLayar()[0] - 3;
int tinggi = ukuranLayar()[1] - 3;

// Posisi awal kadalleo dipilih secara acak dengan minimal margin 3 dari tepi
int posAwalX = acak(3, lebar);
int posAwalY = acak(3, tinggi);

// kadalleo dimulai dengan panjang 5
List<Point<int>> kadalleo = [
  Point(posAwalX, posAwalY),
  Point(posAwalX - 1, posAwalY),
  Point(posAwalX - 2, posAwalY),
  Point(posAwalX - 3, posAwalY),
  Point(posAwalX - 4, posAwalY)
];

// Posisi makanan dipilih secara acak
Point<int> makanan = Point(acak(3, lebar), acak(3, tinggi));

// Variabel untuk menyimpan arah terakhir kadalleo
Point<int> arahTerakhir = Point(1, 0);

void main() async {
  bersihkanLayar();
  bool mulai = true;
  bersihkanLayar();

  if (mulai) {
    bersihkanLayar();
    stdin.echoMode = false;
    stdin.lineMode = false;

    while (true) {
      lebar = ukuranLayar()[0] - 3;
      tinggi = ukuranLayar()[1] - 3;
      if (!gerakkanKadalleo()) {
        bersihkanLayar();
        print("Permainan Berakhir!");
        break;
      }
      gambarGrid();
      await jeda(100);
    }
  }
}

// Fungsi untuk menggerakkan kadalleo otomatis menuju makanan
bool gerakkanKadalleo() {
  final kepala = kadalleo.first;

  Point<int>? langkahBerikutnya = cariLangkahBerikutnya(kepala, makanan);

  if (langkahBerikutnya != null) {
    kadalleo.insert(0, langkahBerikutnya);
    arahTerakhir = Point(langkahBerikutnya.x - kepala.x, langkahBerikutnya.y - kepala.y);

    if (langkahBerikutnya.x < 0 || langkahBerikutnya.x >= lebar || langkahBerikutnya.y < 0 || langkahBerikutnya.y >= tinggi || kadalleo.sublist(1).contains(langkahBerikutnya)) {
      return false;
    }

    if (langkahBerikutnya == makanan) {
      taruhMakanan();
    } else {
      kadalleo.removeLast();
    }
  }
  return true;
}

// Fungsi untuk mencari langkah terbaik menuju makanan
Point<int>? cariLangkahBerikutnya(Point<int> awal, Point<int> target) {
  List<Point<int>> arah = [
    Point(0, 1),
    Point(1, 0),
    Point(0, -1),
    Point(-1, 0)
  ];

  arah.removeWhere((dir) => dir == Point(-arahTerakhir.x, -arahTerakhir.y));

  Point<int>? langkahTerbaik;
  int jarakTerdekat = 9999;
         
  for (var arah in arah) {
    Point<int> posisiBaru = Point(awal.x + arah.x, awal.y + arah.y);

    if (posisiBaru.x >= 0 && posisiBaru.x < lebar && posisiBaru.y >= 0 && posisiBaru.y < tinggi && !kadalleo.contains(posisiBaru)) {
      int jarak = (posisiBaru.x - target.x).abs() + (posisiBaru.y - target.y).abs();
      if (jarak < jarakTerdekat) {
        jarakTerdekat = jarak;
        langkahTerbaik = posisiBaru;
      }
    }
  }

  if (langkahTerbaik == null) {
    Point<int> langkahMundur = Point(awal.x - arahTerakhir.x, awal.y - arahTerakhir.y);
    if (langkahMundur.x >= 0 && langkahMundur.x < lebar && langkahMundur.y >= 0 && langkahMundur.y < tinggi) {
      langkahTerbaik = langkahMundur;
    }
  }

  return langkahTerbaik;
}

// Fungsi untuk menggambar grid
void gambarGrid() async {
  bersihkanLayar();

  int i = 1;
  int posisiX = 0;
  int posisiY = 0;

  for (var s in kadalleo) {
    pindahKe(s.y + 1, s.x + 1);

    if (i == 2 || i == kadalleo.length - 1) {
      stdout.write('O');
      if (posisiX != s.x) {
        pindahKe(s.y + 2, s.x + 1);
        stdout.write('O');
        pindahKe(s.y + 3, s.x + 1);
        stdout.write('O');
        pindahKe(s.y, s.x + 1);
        stdout.write('O');
        pindahKe(s.y - 1, s.x + 1);
        stdout.write('O');
      } else {
        if (posisiY < s.y) {
          pindahKe(s.y + 1, s.x + 2);
          stdout.write('O');
          pindahKe(s.y + 1, s.x + 3);
          stdout.write('O');
          pindahKe(s.y + 1, s.x);
          stdout.write('O');
          pindahKe(s.y + 1, s.x - 1);
          stdout.write('O');
        } else {
          pindahKe(s.y + 1, s.x + 2);
          stdout.write('O');
          pindahKe(s.y + 1, s.x + 3);
          stdout.write('O');
          pindahKe(s.y + 1, s.x);
          stdout.write('O');
          pindahKe(s.y + 1, s.x - 1);
          stdout.write('O');
        }
      }
    } else {
      stdout.write('O');
    }
    posisiX = s.x;
    posisiY = s.y;
    i++;
  }

  pindahKe(kadalleo.first.y + 1, kadalleo.first.x + 1);
  stdout.write('O');

  pindahKe(makanan.y + 1, makanan.x + 1);
  stdout.write('L'); // Mengubah makanan menjadi huruf 'L'
}
