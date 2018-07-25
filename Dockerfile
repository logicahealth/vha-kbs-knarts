FROM nginx
LABEL maintainer="Preston Lee <preston.lee@prestonlee.com"

# We need to make a few changes to the default configuration file.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy slower-moving content directories first.
COPY content superseded /usr/share/nginx/html/

# Copy faster-moving stuffinto the content directory.
COPY index.html LICENSE.txt manifest.json connect.json overview.html /usr/share/nginx/html/
