FROM nginx:alpine

# Add a file containing "Hello SRE!" text that can be accessed via /sre.txt
RUN echo "Hello SRE!" > /usr/share/nginx/html/sre.txt

# Exposing port 80
EXPOSE 80

# Default command
CMD ["nginx", "-g", "daemon off;"] 