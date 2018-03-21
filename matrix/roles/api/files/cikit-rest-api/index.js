const app = require('./lib/app');

app.listen(app.port, () => app.log.info('Express server listening on port ' + app.port));
