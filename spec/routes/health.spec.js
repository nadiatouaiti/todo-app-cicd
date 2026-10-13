const db = require('../../src/persistence');
const health = require('../../src/routes/health');

jest.mock('../../src/persistence', () => ({
    getItems: jest.fn(),
}));

// On fait taire console.error pendant le test d'erreur
beforeEach(() => jest.spyOn(console, 'error').mockImplementation(() => {}));
afterEach(() => jest.restoreAllMocks());

test('returns 200 when the database responds', async () => {
    const res = { send: jest.fn(), status: jest.fn() };
    db.getItems.mockResolvedValue([]);

    await health({}, res);

    expect(res.status).not.toHaveBeenCalled();
    expect(res.send).toHaveBeenCalledWith({ status: 'ok' });
});

test('returns 503 when the database fails', async () => {
    const res = { send: jest.fn(), status: jest.fn() };
    res.status.mockReturnValue(res); // permet res.status(503).send(...)
    db.getItems.mockRejectedValue(new Error('db down'));

    await health({}, res);

    expect(res.status).toHaveBeenCalledWith(503);
    expect(res.send).toHaveBeenCalledWith({ status: 'error' });
});