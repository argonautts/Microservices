FROM alpine:latest
RUN mkdir /app

COPY front-end/frontApp /app

# Run the server executable
CMD [ "/app/frontApp" ]