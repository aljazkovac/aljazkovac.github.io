Intercepting a request based on its value, and then doing something other than just trying to serve a matching file 
relative to the root directory.

```nginx
events {}

http {

    # Load the types (e.g., css)
    include mime.types;

    server {
        listen 80;
        server_name 206.189.100.37;

        # Will look for files at the defined root
        root /var/www/demo;

        # Each of the location modifiers below is assigned a priority.
        # Here is the priority order:
        # 1. Exact match (=)
        # 2. Preferential prefix match (^~)
        # 3. REGEX match (~*)
        # 4. Prefix match ()

        # Prefix match (this will match anything starting with 'greet', e.g., 'greeting', 'greet/more', etc.)
        # location /Greet2 {
        #     return 200 'Hello from Nginx "/Greet2" location - PREFIX MATCH.';
        # }

        # Preferential prefix match (this will match anything starting with 'greet', e.g., 'greeting', 'greet/more', etc.)
        location ^~ /Greet2 {
            return 200 'Hello from Nginx "/Greet2" location - PREFERENTIAL PREFIX MATCH.';
        }

        # Exact match
        # location = /greet {
        #     return 200 'Hello from Nginx "/greet" location - EXACT MATCH.';
        # }

        # Regex match - case sensitive!
        # location ~ /greet[0-9] {
        #     return 200 'Hello from Nginx "/greet" location - REGEX MATCH SENSITIVE.';
        # }

        # Regex match - case insensitive!
        location ~* /greet[0-9] {
            return 200 'Hello from Nginx "/greet" location - REGEX MATCH INSENSITIVE.';
        }
    }
}
```
