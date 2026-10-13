const db = require('../persistence');

// Health check : l'app répond ET la base de données est joignable.
// 200 = OK, 503 = l'app tourne mais ne peut pas servir les requêtes.
module.exports = async (req, res) => {
    try {
        await db.getItems();
        res.send({ status: 'ok' });
    } catch (err) {
        console.error('Health check failed:', err.message);
        res.status(503).send({ status: 'error' });
    }
};
