## Scutum Admin Laravel Sanctum integration

### API Installation:

1. Install laravel and set DB credentials:
```bash
composer create-project --prefer-dist laravel/laravel sanctum-nuxt-api
```

```bash
cd sanctum-nuxt-api
```
open .env file and update following fields

```
DB_DATABASE=
DB_USERNAME=
DB_PASSWORD=
```

2. install Laravel Sanctum
```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```
	
3. Install Laravel Breeze
```bash
composer require laravel/breeze --dev
php artisan breeze:install
npm install
npm run dev
```

4. Configuration

Open `app/Http/Kernel.php` and add Sanctum middleware `\Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class` to api middleware
   
	
```php		
protected $middlewareGroups = [
	...

	'api' => [
		\Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class // here
		'throttle:60,1',
		\Illuminate\Routing\Middleware\SubstituteBindings::class,
	],
];
```
	
Open `config/cors.php` and change following variables

	'paths' => ['*']
	'supports_credentials' => true


Open `routes/api.php` and add Sanctum auth middleware
```php
Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
	return $request->user();
});
```

Open `.env` file and set following variables
```
SESSION_DRIVER=cookie
SESSION_DOMAIN=.example.com // api and front app domain (api.example.com;front.example.com), remember to add . before domain
SANCTUM_STATEFUL_DOMAINS=front.example.com // nuxt.js app domain
```
