#!/bin/bash
echo "Starting post-create script..."

# Update package lists and install system dependencies for Odoo
# libpq-dev is for psycopg2, wkhtmltopdf is handled by feature but other Odoo deps might be needed
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    build-essential \
    libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev \
    libtiff5-dev libjpeg62-turbo-dev libopenjp2-7-dev zlib1g-dev \
    libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev \
    libxcb1-dev node-less node-clean-css # Added node-less & node-clean-css

# Clone Odoo source code (version 18.0)
echo "Cloning Odoo 18.0..."
git clone https://github.com/odoo/odoo.git --depth 1 --branch 18.0 /workspaces/odoo_src

# Create a virtual environment for Odoo & install Python dependencies
echo "Setting up Python virtual environment and installing Odoo dependencies..."
# The base Python from devcontainer is used directly, pip install --user or specific venv is an option
# For simplicity, we'll install into the user's site-packages accessible by the container's Python
pip install --user -r /workspaces/odoo_src/requirements.txt

# Create a directory for custom addons in your repository workspace
if [ ! -d "/workspaces/$(basename $PWD)/custom_addons" ]; then
    mkdir "/workspaces/$(basename $PWD)/custom_addons"
    echo "Created 'custom_addons' directory in your repository."
fi
# Create a basic odoo.conf
echo "Creating a basic odoo.conf..."
cat << EOF > /workspaces/odoo_src/odoo.conf
[options]
admin_passwd = admin
db_host = localhost
db_port = 5432
; db_user and db_password will be set after you create the PostgreSQL user
; db_user = odoo_user
; db_password = your_chosen_password
addons_path = /workspaces/odoo_src/odoo/addons,/workspaces/odoo_src/addons,/workspaces/$(basename $PWD)/custom_addons
EOF
echo "A basic odoo.conf has been created in /workspaces/odoo_src."
echo "IMPORTANT: You still need to create a PostgreSQL user for Odoo and update odoo.conf with its credentials."
echo "Post-create script finished."
