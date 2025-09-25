# Basic HTTP echo server for testing purposes
FROM hashicorp/http-echo:0.2.3
# Optional Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget -qO- http://localhost:5678/ || exit 1
# Overide default text
CMD ["-text=Hello from Bonmoja!", "-listen=:5678"]