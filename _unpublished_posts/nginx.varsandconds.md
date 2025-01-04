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

        # LOCATIONS

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
        # location ^~ /Greet2 {
        #     return 200 'Hello from Nginx "/Greet2" location - PREFERENTIAL PREFIX MATCH.';
        # }

        # Exact match
        # location = /greet {
        #     return 200 'Hello from Nginx "/greet" location - EXACT MATCH.';
        # }

        # Regex match - case sensitive!
        # location ~ /greet[0-9] {
        #     return 200 'Hello from Nginx "/greet" location - REGEX MATCH SENSITIVE.';
        # }

        # Regex match - case insensitive!
        # location ~* /greet[0-9] {
        #     return 200 'Hello from Nginx "/greet" location - REGEX MATCH INSENSITIVE.';
        # }

        # VARIABLES and CONDITIONALS 
        # location /inspect {
        #     return 200 "$host\n$uri\n$args";
        # }

        location /inspect {
            # Returns Name: <name> if name is provided as a query string.
            return 200 "Name: $arg_name"; 
        }

        # Check static API key
        # if ( $arg_apikey != 1234 ) {
        #     # Even when passing apikey the image and stylesheet will be missing
        #     # since the internal requests don't include the apikey parameter.
        #     return 401 "Incorrect API key";
        # }

        # Variables can be set to:
        # 1. Strings
        # 2. Integers
        # 3. Booleans
        set $weekend 'No';

        # Check if weekend
        # Use Regex to check if variable includes one of the strings
        if ( $date_local ~ 'Saturday|Sunday' ) {
            set $weekend 'Yes';
        }

        location /isweekend {
            return 200 $weekend;
        }

        set $wed 'No';

        # Check if Wednesday
        # Use Regex to check if variable includes one of the strings
        if ( $date_local ~ 'Wednesday' ) {
            set $wed 'Yes';
        }

        location /iswed {
            return 200 $wed;
        }

    }
}
```
