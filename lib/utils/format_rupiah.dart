String formatRupiah(int value) {
  return "Rp${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}";
}
