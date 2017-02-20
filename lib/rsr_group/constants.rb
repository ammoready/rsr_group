module RsrGroup

  FILE_TYPES = {
    'EERR'  => 'Error',
    'ECONF' => 'Confirmation',
    'ESHIP' => 'Shipping',
  }

  LINE_TYPES = {
    '00' => :file_header,
    '10' => :order_header,
    '11' => :ffl_dealer,
    '20' => :order_detail,
    '30' => :confirmation_header,
    '40' => :confirmation_detail,
    '50' => :confirmation_trailer,
    '60' => :shipping_header,
    '70' => :shipping_detail,
    '80' => :shipping_trailer,
    '90' => :order_trailer,
    '99' => :file_trailer,
  }

  SHIPPING_CARRIERS = %w(UPS USPS)

  SHIPPING_METHODS = {
    'Grnd' => 'Ground',
    '1Day' => 'Next Day Air',
    '2Day' => '2nd Day Air',
    '3Day' => '3 Day Select', 
    'NDam' => 'Next Day Early AM',
    'NDAS' => 'Next Day Air Saver',
    'PRIO' => 'Priority'
  }

  ERROR_CODES = {
    '00001' => 'File Header record missing',
    '00002' => 'Invalid date',
    '00003' => 'Duplicate file',
    '00004' => 'Invalid Etailer number',
    '00005' => 'Empty file',
    '00006' => 'Invalid Sequence number',
    '10001' => 'Order Header record missing',
    '10002' => 'Invalid ship‐to name',
    '10003' => 'Missing ship‐to address',
    '10004' => 'Invalid ship‐to city',
    '10005' => 'Invalid ship‐to state',
    '10006' => 'Invalid ship‐to zip',
    '10007' => 'Invalid phone',
    '10008' => 'Invalid email option',
    '10009' => 'Invalid email address',
    '10010' => 'Duplicate order',
    '10011' => 'No orders found ',
    '10012' => 'Invalid ship‐to address ',
    '10013' => 'Invalid ship‐to county ',
    '10014' => 'Order Cancelled',
    '10099' => 'No quantity available',
    '10999' => 'Miscellaneous',
    '11000' => 'FFL Dealer record missing',
    '11001' => 'Account is not setup for firearm shipments',
    '11002' => 'Dealer FFL not found',
    '11003' => 'Dealer zip code mismatch',
    '11004' => 'Dealer name mismatch',
    '11005' => 'Dealer state mismatch',
    '11006' => 'Dealer FFL expired',
    '11007' => 'Firearms combined with accessories',
    '11008' => 'Dealer deactivated',
    '11999' => 'Miscellaneous',
    '20001' => 'Order Detail record missing',
    '20002' => 'Invalid RSR stock number',
    '20003' => 'Invalid quantity ordered',
    '20004' => 'Invalid shipping carrier',
    '20005' => 'Invalid shipping method',
    '20006' => 'Duplicate item in order',
    '20007' => 'Item out of stock',
    '20008' => 'Item prohibited',
    '20009' => 'Phone number required',
    '20010' => 'RSR allocated',
    '20011' => 'Case quantity required',
    '20999' => 'Miscellaneous',
    '30001' => 'OrderTrailerrecordmissing',
    '30002' => 'Invalid total order amount',
    '30003' => 'Mismatch on number of items ordered and number specified on order trailer record',
    '99001' => 'File Trailer record missing',
    '99002' => 'Invalid quantity ordered',
    '99003' => 'Mismatch on number of orders found and total quantity specified on file trailer record',
  }

end