FROM nginx
LABEL maintainer="Preston Lee <preston.lee@prestonlee.com"

# We need to make a few changes to the default configuration file.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy content directories first.
COPY content superseded /usr/share/nginx/html/

# Copy everything else into the content directory.
COPY . /usr/share/nginx/html/
