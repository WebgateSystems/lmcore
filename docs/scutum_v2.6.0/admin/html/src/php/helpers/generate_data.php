<?php
require_once realpath(__DIR__).'/vendor/autoload.php';

// PHP library that generates fake data
$faker = Faker\Factory::create();

use Carbon\Carbon;

echo $faker->email;
echo $faker->bankAccountNumber;
echo $faker->userName;

$names = [];
$company = [
	'name' => $faker->company,
	'addres1' => $faker->streetAddress,
	'addres2' => $faker->city
];
$vat = ['9','23'];
$items = [];
for($i=0;$i<10;$i++) {
	$_price = round( (floatval($faker->numberBetween( 10, 300 ) . '.' . $faker->numberBetween( 10, 99 ))), 2);
	$_vat = $vat[array_rand($vat)];
	$_qt = intval(rand(1,6));
	$items[ $i ] = array(
		'name'          => 'Item ' . rand(10,80) . ' Name',
		'description'   => $faker->sentence( 10 ),
		'quantity'      => $_qt,
		'price'         => $_price,
		'VAT'           => intval($vat[array_rand($vat)]),
		'total'         => ( round(($_price * (intval($_vat)/100)), 2 )  +  $_price) * $_qt
	);
};

for($i=0;$i<20;$i++) {
	$dt = new Carbon();
	$locales = $i === 4 || $i === 12 ? 'fr-FR' : 'en-US';
	$currency = $i === 4 || $i === 12 ? 'EUR' : 'USD';
	$names[$i]['id'] = $faker->uuid;
	$names[$i]['locales'] = $locales;
	$names[$i]['currency'] = $currency;
	$names[$i]['number'] = (84 - $i) .'/envato/2020';
	$names[$i]['date'] = $dt->subDay($i)->format('d/m/Y');
	// $names[$i]['invoice_from_company'] = $company['name'];
	// $names[$i]['invoice_from_address_1'] = $company['addres1'];
	// $names[$i]['invoice_from_address_2'] = $company['addres2'];
	$names[$i]['to_company'] = $faker->company;
	$names[$i]['to_address_1'] = $faker->streetAddress;
	$names[$i]['to_address_2'] = $faker->city;
	$names[$i]['phone'] = $faker->phoneNumber;
	$items_uniq = $items;
	$arr_items = [];
	for($ii=0;$ii<rand(2,6);$ii++) {
		shuffle($items_uniq);
		$randEl = array_pop($items_uniq);
		$arr_items[$ii] = $randEl;
	}
	$names[$i]['items'] = $arr_items;
	//$names[$i]['invoice_total_value'] = $faker->numberBetween(1000,10000).'.'. $faker->numberBetween(10,99);
	//$names[$i]['invoice_vat'] = '23';
	// $names[$i]['fName'] = $faker->firstName;
	// $names[$i]['lName'] = $faker->lastName;
	// $names[$i]['company'] = $faker->company;
	// $names[$i]['email'] = $faker->email;
}

echo '<pre>';
echo json_encode($names);
echo '</pre>';

?>