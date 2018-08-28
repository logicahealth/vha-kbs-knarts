FROM nginx
LABEL maintainer="Preston Lee <preston.lee@prestonlee.com"

# We need to make a few changes to the default configuration file.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy slower-moving content directories first.
COPY superseded /usr/share/nginx/html/superseded
COPY content /usr/share/nginx/html/content

# Copy faster-moving stuffinto the content directory.
COPY index.html LICENSE.txt manifest.json connect.json /usr/share/nginx/html/
