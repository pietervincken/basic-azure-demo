# ACI Postgres

This deployment uses PHPPGAdmin container with a postgres backend. 
It automatically deploys through Terraform and populates the database with 5000 records of user data when created.

## Usage

- `sh generate-data.sh`: this will refresh the random user data in `users.sql`