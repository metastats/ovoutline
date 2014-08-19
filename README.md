## Clone
    git clone -b master https://github.com/metastats/ovoutline.git
    cd ovoutline
    git checkout -b gh-pages origin/gh-pages
    git checkout -b workspace master
    git checkout gh-pages -- index.html css lib
    git commit -m 'My clone' 
    
## Web server
    ruby -run -e httpd . -p 9090
    python -m SimpleHTTPServer 8080
