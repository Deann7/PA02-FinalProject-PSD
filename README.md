
# Final Project PSD PA02 - VHDL Powered Cryptography with Caesar and Hill Cipher on FPGA

### Kelompok PA-2 FINPRO PSD
- DEANDRO NAJWAN AHMAD S	(2306213174)
- KHARISMA APRILIA			(2306223244)
- REYHAN AHNAF DEANNOVA	    (2306267100)
- SHAFWAN HASYIM			(2306209113)

**Aslab : Bang Nicholas (NS)**


## Background
Keamanan informasi menjadi salah satu aspek penting dalam dunia digital saat ini. Dengan berkembangnya teknologi informasi, ancaman terhadap data pribadi dan data sensitif semakin meningkat. Oleh karena itu, enkripsi data penting untuk melindungi informasi agar tetap aman. Enkripsi dengan menggunakan metode yang kuat seperti Caesar Cipher dan Hill Cipher menjadi salah satu solusi untuk memastikan data tetap aman. Proyek ini bertujuan untuk mengimplementasikan sistem enkripsi dan dekripsi menggunakan kedua algoritma tersebut dalam FPGA.

## Deskripsi Proyek
Proyek ini merupakan implementasi sistem enkripsi dan dekripsi menggunakan dua metode kriptografi populer yaitu Caesar Cipher dan Hill Cipher. Sistem ini memungkinkan pengguna untuk mengenkripsi dan mendekripsi pesan atau data menggunakan algoritma enkripsi berbasis kunci. Proyek ini terdiri dari dua mode operasi: mode enkripsi dan mode dekripsi. Pada mode enkripsi, sistem akan mengenkripsi data menggunakan Caesar Cipher dan Hill Cipher. Pada mode dekripsi, sistem akan mendekripsi data yang telah dienkripsi sebelumnya. File input dan output yang digunakan dalam proyek ini adalah file txt dan proses enkripsi-dekripsi akan dilakukan secara berurutan dengan pembacaan dan penulisan data dari dan ke file.

## Cara Kerja
Sistem ini bekerja dengan menggunakan dua algoritma enkripsi, yaitu Caesar Cipher dan Hill Cipher, yang diterapkan secara berurutan untuk mengenkripsi dan mendekripsi data. Proses dimulai dengan pembukaan file input yang berisi pesan atau data yang akan dienkripsi atau didekripsi. Dalam mode enkripsi, sistem pertama-tama mengenkripsi data menggunakan Hill Cipher, kemudian hasil enkripsi dari Hill Cipher akan dienkripsi kembali menggunakan Caesar Cipher. Hasil akhirnya akan disimpan dalam file output yang berbeda. Sebaliknya, dalam mode dekripsi, sistem pertama-tama membaca data yang telah dienkripsi dan mendekripsi data tersebut menggunakan Caesar Cipher dan Hill Cipher secara berurutan. Semua operasi ini dilakukan dalam sebuah state machine, dengan setiap tahap memastikan bahwa file dibuka, diproses, dan ditutup dengan benar. Setelah proses selesai, file output akan berisi hasil enkripsi atau dekripsi yang diinginkan, dan sistem akan kembali ke kondisi awal untuk menunggu proses berikutnya.


