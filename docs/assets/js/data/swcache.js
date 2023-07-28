const resource = [
    /* --- CSS --- */
    '/FileTreeHasher/assets/css/style.css',

    /* --- PWA --- */
    '/FileTreeHasher/app.js',
    '/FileTreeHasher/sw.js',

    /* --- HTML --- */
    '/FileTreeHasher/index.html',
    '/FileTreeHasher/404.html',

    
        '/FileTreeHasher/downloads',
    
        '/FileTreeHasher/documentation',
    
        '/FileTreeHasher/release-notes',
    
        '/FileTreeHasher/known-issues',
    
        '/FileTreeHasher/about',
    

    /* --- Favicons & compressed JS --- */
    
    
        '/FileTreeHasher/assets/img/favicons/android-chrome-192x192.png',
        '/FileTreeHasher/assets/img/favicons/android-chrome-512x512.png',
        '/FileTreeHasher/assets/img/favicons/apple-touch-icon.png',
        '/FileTreeHasher/assets/img/favicons/favicon-16x16.png',
        '/FileTreeHasher/assets/img/favicons/favicon-32x32.png',
        '/FileTreeHasher/assets/img/favicons/favicon.ico',
        '/FileTreeHasher/assets/img/favicons/mstile-144x144.png',
        '/FileTreeHasher/assets/img/favicons/mstile-150x150.png',
        '/FileTreeHasher/assets/img/favicons/mstile-310x150.png',
        '/FileTreeHasher/assets/img/favicons/mstile-310x310.png',
        '/FileTreeHasher/assets/img/favicons/mstile-70x70.png',
        '/FileTreeHasher/assets/img/favicons/safari-pinned-tab.svg',
        '/FileTreeHasher/assets/js/dist/categories.min.js',
        '/FileTreeHasher/assets/js/dist/commons.min.js',
        '/FileTreeHasher/assets/js/dist/home.min.js',
        '/FileTreeHasher/assets/js/dist/misc.min.js',
        '/FileTreeHasher/assets/js/dist/page.min.js',
        '/FileTreeHasher/assets/js/dist/post.min.js'
];

/* The request url with below domain will be cached */
const allowedDomains = [
    

    'localhost:4000',

    

    'fonts.gstatic.com',
    'fonts.googleapis.com',
    'cdn.jsdelivr.net',
    'polyfill.io'
];

/* Requests that include the following path will be banned */
const denyUrls = [];

