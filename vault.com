upstream vault {
        server 127.0.0.1:8200 max_fails=0 fail_timeout=0;
}

server {
        server_name vault.asilbek.com;

        location / {
                proxy_pass http://vault;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
                client_max_body_size 0;
        }
        access_log /var/log/nginx/app-access.log;
        error_log /var/log/nginx/app-error.log;

       



}