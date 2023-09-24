docker rm -f admin

docker run --name admin -p 8080:80 -d \
    -e "PHP_PG_ADMIN_EXTRA_LOGIN_SECURITY=yes" \
    -e "PHP_PG_ADMIN_SERVER_SSL_MODE=require" \
    -e "PHP_PG_ADMIN_SERVER_HOST=pgs-azuredemoap.postgres.database.azure.com" \
    -e "PHP_PG_ADMIN_SERVER_DEFAULT_DB=demodb" \
    bitnami/phppgadmin-archived
