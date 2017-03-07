module SampleFiles

  def sample_inventory_txt
    <<-TXT.chomp
PRODUCT1;800000123101;PRODUCT1;34;Brand1;100.99;90.00; 2;21;;Brand1;PRODUCT1;;Great product;product1.jpg;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;20161103;29.44;;2.50;1.50;1.50;
PRODUCT2;800000123702;PRODUCT2;01;Brand2;200.99;190.00;75; 0;Brand2;PRODUCT2;PRODUCT2;;Great product;product2.jpg;;;;;Y;;;;;;;;;;;;;;;Y;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Y;Y;20161028;.00;;13.25;11.50;3.50; 
PRODUCT3;800000123103;PRODUCT3;09;Brand3;300.99;290.00; 5;21;Brand3;PRODUCT3;PRODUCT3;;Great product;product3.jpg;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;20161213;67.50;;4.75;2.25;2.25; 
PRODUCT4;800000123404;PRODUCT4;26;Brand4;400.99;390.00; 9;32;Brand4;PRODUCT4;PRODUCT4;;Great product;product4.jpg;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;20260307;.00;;9.00;6.00;4.50; 
    TXT
  end

  def sample_map_prices_csv
    <<-TXT
PRODUCT1,0000838.85
PRODUCT2 ,0000038.90
PRODUCT3 ,0000199.00
PRODUCT4,0000838.85
    TXT
  end

  def sample_quantity_csv
    <<-TXT.chomp
PRODUCT1,0000020
PRODUCT2,0000010
PRODUCT3,0000000
PRODUCT4,0000300
    TXT
  end

  def test_eord_file
    <<-TXT.chomp
FILEHEADER;00;12345;20161212;0001
1000-400;10;Bellatrix;;123 Winchester Ave;;Happyville;CA;12345;888999000;Y;email@example.com;;
1000-400;11;aa-bb-01-cc;Balrog;22122
1000-400;20;BRS34002;00001;USPS;PRIO
1000-400;20;AUT12KT;00001;USPS;PRIO
1000-400;90;0000002
FILETRAILER;99;00001
    TXT
  end

  def test_eerr_file
    <<-TXT.chomp
FILEHEADER;00;12345;20161117;0001;00000
4000-1000;10;Bellatrix;;123 Winchester Ave;;Happyville;CA;296012162;888999000;Y;email@example.com;;00000
4000-1000;20;MPIMAG485GRY;0000001;USPS;PRIO;20005
4000-1000;20;CS20NPKZ;0000001;USPS;PRIO;20005
4000-1000;90;0000002;00000
FILETRAILER;99;00001;00000
    TXT
  end

  def test_econf_file
    <<-TXT.chomp
FILEHEADER;00;RSRGP;20161117;0002;
4000-1020;30;17222;
4000-1020;40;CS20NPKZ;0000001;0000001;
4000-1020;40;MPIMAG485GRY;0000001;0000000;
4000-1020;50;000000002;000000001;
FILETRAILER;99;0000001;
    TXT
  end

  def test_eship_file
    <<-TXT.chomp
FILEHEADER;00;RSRGP;99999;20161117;
5000-2000;60;Bellatrix;1Z7539320314612868;58776;20161117;0000000800;0000000000;UPS;Grnd;
5000-2000;70;CS20NPKZ;00001;00001;
5000-2000;70;MPIMAG485GRY;00001;00001;
5000-2000;80;000000004;000000004;
FILETRAILER;99;0000001;
    TXT
  end

end
