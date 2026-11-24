<?php

/**
 * PostfixAdmin Clean URL Front Controller.
 *
 * Configure your web server (Nginx/Apache) to route non-static requests here
 * and set $CONF['clean_urls'] = 'YES'; in config.local.php.
 * See DOCUMENTS/CLEAN_URLS.md for web server examples.
 */

// Allow PHP's built-in development server (`php -S`) to serve static non-PHP files strictly within public/
if (PHP_SAPI === 'cli-server') {
    $reqPath = (string) (parse_url((string) ($_SERVER['REQUEST_URI'] ?? '/'), PHP_URL_PATH) ?: '/');
    $publicRoot = realpath(__DIR__);
    $candidate = realpath(__DIR__ . '/' . ltrim($reqPath, '/'));
    if (
        $publicRoot !== false
        && $candidate !== false
        && strpos($candidate, $publicRoot . DIRECTORY_SEPARATOR) === 0
        && is_file($candidate)
        && strtolower(pathinfo($candidate, PATHINFO_EXTENSION)) !== 'php'
    ) {
        return false;
    }
}

require_once __DIR__ . '/../model/Router.php';

// Read optional uncommented base_url_path without requiring full bootstrap (allows /setup and unconfigured / to work)
$basePath = '';
if (is_file(__DIR__ . '/../config.local.php')) {
    $localSnippet = @file_get_contents(__DIR__ . '/../config.local.php');
    if (is_string($localSnippet)) {
        $basePath = Router::extractBaseUrlPathFromSnippet($localSnippet);
    }
}

$requestUri = (string) ($_SERVER['REQUEST_URI'] ?? '/');
$requestPath = (string) (parse_url($requestUri, PHP_URL_PATH) ?: '/');

$route = Router::resolve($requestPath, $basePath);

if ($route === null) {
    http_response_code(404);
    header('Content-Type: text/plain; charset=UTF-8');
    echo '404 Not Found';
    exit;
}

$targetDir = $route['user_context'] ? (__DIR__ . '/users') : __DIR__;
$targetFile = $targetDir . '/' . $route['script'];

if (!is_file($targetFile)) {
    http_response_code(404);
    header('Content-Type: text/plain; charset=UTF-8');
    echo '404 Not Found';
    exit;
}

// Populate route parameters (e.g. /edit/mailbox -> $_GET['table'] = 'mailbox', and $_POST['table'] on POST)
$isPost = strtoupper((string) ($_SERVER['REQUEST_METHOD'] ?? 'GET')) === 'POST';
foreach ($route['params'] as $paramKey => $paramVal) {
    if (!isset($_GET[$paramKey])) {
        $_GET[$paramKey] = $paramVal;
    }
    if ($isPost && !isset($_POST[$paramKey])) {
        $_POST[$paramKey] = $paramVal;
    }
    if (!isset($_REQUEST[$paramKey])) {
        $_REQUEST[$paramKey] = $paramVal;
    }
}

// Register Location header rewriter so redirects stay on clean URLs
Router::registerLocationRewriter($route['user_context'], $basePath);

// Preserve relative include semantics for scripts in public/ and public/users/
chdir($targetDir);
require $targetFile;
