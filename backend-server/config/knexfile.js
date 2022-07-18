// Update with your config settings.

module.exports = {

  development: {
    client: 'postgresql',
    connection: {
      database: 'hungrilydb',
      user:     'postgres',
      password: ''
    }
  },

  staging: {
    client: 'postgresql',
    connection: {
      database: 'hungrilydb',
      user:     'hungrilyapp',
      password: '12345'
    }
  },

  production: {
    client: 'postgresql',
    connection: {
      database: 'hungrilydb',
      user:     'hungrilyapp',
      password: '12345'
    }
  }

};
