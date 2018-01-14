# web-vlc
A website for selecting shows to watch on VLC locally

# Usage

Install dependencies.

```
npm i
```

Edit `server/config.coffee` to your defaults.

Compile CoffeeScript and Webpack.

```
npm run build
```

Run the server.

```
npm start
```

Navigate to the application at `http://localhost:3000`.
Note your path may be different if you changed the config.

# Development

Watch for CoffeeScript changes.

```
npm run coffee-watch
```

Watch for Webpack changes.

```
npm run webpack-watch
```

Run server watching for changes.

```
npm run start-watch
```
