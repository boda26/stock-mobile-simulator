const express = require('express');
const app = express();
const cors = require('cors');

const finnhub_key = 'cn0i2k1r01quegsjprmgcn0i2k1r01quegsjprn0'
const polygon_key = 'ajnnGkZ3HgTrZPpQVMdPcpxorTjkyOqI'

const { MongoClient, ObjectId } = require('mongodb');
const bodyParser = require('body-parser');
const mongoUrl = 'mongodb+srv://boda26:woshisongboda@stockcluster.1sz6q8j.mongodb.net/?retryWrites=true&w=majority&appName=stockCluster'
const client = new MongoClient(mongoUrl);
const dbName = 'mobileDB'
app.use(bodyParser.json());

app.use(cors());

app.get('/api/watchlist', async (req, res) => {
    try {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection('watchlistCollection');
        const data = await collection.find({}).toArray();
        res.json(data);
    } catch (err) {
        res.status(500).send(err);
    }
})

app.post('/api/watchlist', async (req, res) => {
    try {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection('watchlistCollection');
        const result = await collection.insertOne(req.body);
        res.status(201).send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

app.delete('/api/watchlist/:id', async (req, res) => {
    try {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection('watchlistCollection');

        const result = await collection.deleteOne({ _id: new ObjectId(req.params.id) });
    
        if (result.deletedCount === 0) {
            return res.status(404).send({ 'message': 'No document found with the specified id' });
        }

        res.send({ 'message': 'Document deleted successfully' });
    } catch (err) {
        res.status(500).send(err);
    }
});

app.put('/api/watchlist/:id', async (req, res) => {
    await client.connect();
    const db = client.db(dbName);
    const collection = db.collection('watchlistCollection');
    const id = req.params.id;
    const filter = { _id: new ObjectId(id) };
    const updateDoc = {
      $set: req.body,
    };
  
    try {
      const result = await collection.updateOne(filter, updateDoc);
      if (result.matchedCount === 0) {
        return res.status(404).send('No document found with that ID');
      }
      res.status(200).send(`Updated document with _id: ${id}`);
    } catch (err) {
      console.error('Update error:', err);
      res.status(500).send('Error updating document');
    }
});

// portfolio db functions

app.get('/api/portfolio', async(req, res) => {
    try {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection('portfolioCollection');
        const data = await collection.find({}).toArray();
        res.json(data);
    } catch (err) {
        res.status(500).send(err);
    }
})

app.post('/api/portfolio', async (req, res) => {
    try {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection('portfolioCollection');
        const result = await collection.insertOne(req.body);
        res.status(201).send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

app.delete('/api/portfolio/:id', async (req, res) => {
    try {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection('portfolioCollection');

        const result = await collection.deleteOne({ _id: new ObjectId(req.params.id) });
    
        if (result.deletedCount === 0) {
            return res.status(404).send({ 'message': 'No document found with the specified id' });
        }

        res.send({ 'message': 'Document deleted successfully' });
    } catch (err) {
        res.status(500).send(err);
    }
});

app.put('/api/portfolio/:id', async (req, res) => {
    await client.connect();
    const db = client.db(dbName);
    const collection = db.collection('portfolioCollection');
    const id = req.params.id;
    const filter = { _id: new ObjectId(id) };
    const updateDoc = {
      $set: req.body,
    };
  
    try {
      const result = await collection.updateOne(filter, updateDoc);
      if (result.matchedCount === 0) {
        return res.status(404).send('No document found with that ID');
      }
      res.status(200).send(`Updated document with _id: ${id}`);
    } catch (err) {
      console.error('Update error:', err);
      res.status(500).send('Error updating document');
    }
});

// db balance functions
app.get('/api/balance', async(req, res) => {
    try {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection('balanceCollection');
        const data = await collection.find({}).toArray();
        res.json(data);
    } catch (err) {
        res.status(500).send(err);
    }
})

app.put('/api/balance/:id', async (req, res) => {
    await client.connect();
    const db = client.db(dbName);
    const collection = db.collection('balanceCollection');
    const id = req.params.id;
    const filter = { _id: new ObjectId(id) };
    const updateDoc = {
      $set: req.body,
    };
  
    try {
        const result = await collection.updateOne(filter, updateDoc);
        if (result.modifiedCount === 0) {
            return res.status(404).send(`No balance found with _id: ${id}`);
        }
        res.status(200).send(`Updated balance with _id: ${id}`);
    } catch (err) {
        console.error('Update error:', err);
        res.status(500).send('Error updating document');
    }
});
  

app.get('/', (req, res) => {
    res.send('Hello Stock Mobile App Backend!');
});

// company profile
app.get('/api/profile/:ticker', async (req, res) => {
    let ticker = req.params.ticker;
    let companyUrl = `https://finnhub.io/api/v1/stock/profile2?symbol=${ticker}&token=${finnhub_key}`;
    let response = await fetch(companyUrl);
    let data = await response.json();
    res.json(data);
});

// history
app.get('/api/history/:ticker', async (req, res) => {
    let ticker = req.params.ticker;
    let startDate = new Date();
    startDate.setYear(startDate.getFullYear() - 2);
    startDate.setDate(startDate.getDate() - 1);
    startDate = startDate.getFullYear() + '-' + 
    ('0' + (startDate.getMonth() + 1)).slice(-2) + '-' +
    ('0' + startDate.getDate()).slice(-2);
    let currentDate = new Date();
    let endDate = currentDate.getFullYear() + '-' +
    ('0' + (currentDate.getMonth() + 1)).slice(-2) + '-' +
    ('0' + currentDate.getDate()).slice(-2);

    let polygonUrl = `https://api.polygon.io/v2/aggs/ticker/${ticker}/range/1/day/${startDate}/${endDate}?adjusted=true&sort=asc&apiKey=${polygon_key}`
    let response = await fetch(polygonUrl);
    let data = await response.json();
    if (data.status === 'ERROR') {
        data = {}
    }
    res.json(data);
});

// hourly price
app.get('/api/hourly/:ticker', async (req, res) => {
    let ticker = req.params.ticker;
    let currentDate = new Date()
    let prevDate = new Date()

    if (currentDate.getDay() == 6) {
        currentDate.setDate(currentDate.getDate() - 1)
        prevDate.setDate(currentDate.getDate() - 1)
    } else if (currentDate.getDay() == 0) {
        currentDate.setDate(currentDate.getDate() - 2)
        prevDate.setDate(currentDate.getDate() - 1)
    } else if (currentDate.getDay() == 1) {
        currentDate.setDate(currentDate.getDate() - 3)
        prevDate.setDate(currentDate.getDate() - 1)
    } else {
        if ((currentDate.getHours() > 6 || (currentDate.getHours() == 6 && currentDate.getMinutes() >= 30)) && currentDate.getHours() < 13) {
            prevDate.setDate(currentDate.getDate() - 1)
        } else {
            currentDate.setDate(currentDate.getDate() - 1)
            prevDate.setDate(currentDate.getDate() - 1)
        }
    }
    prevDate = prevDate.getFullYear() + '-' + 
        ('0' + (prevDate.getMonth() + 1)).slice(-2) + '-' +
        ('0' + prevDate.getDate()).slice(-2);
    currentDate = currentDate.getFullYear() + '-' +
        ('0' + (currentDate.getMonth() + 1)).slice(-2) + '-' +
        ('0' + currentDate.getDate()).slice(-2);

    let polygonUrl = `https://api.polygon.io/v2/aggs/ticker/${ticker}/range/1/hour/${prevDate}/${currentDate}?adjusted=true&sort=asc&apiKey=${polygon_key}`
    let response = await fetch(polygonUrl);
    let data = await response.json();
    res.json(data);
})

// quote
app.get('/api/quote/:ticker', async (req, res) => {
    let ticker = req.params.ticker;
    let quoteUrl = `https://finnhub.io/api/v1/quote?symbol=${ticker}&token=${finnhub_key}`
    let response = await fetch(quoteUrl);
    let data = await response.json();
    res.json(data);
});

// autocomplete
app.get('/api/autocomplete/:query', async (req, res) => {
    let query = req.params.query;
    let autoUrl = `https://finnhub.io/api/v1/search?q=${query}&token=${finnhub_key}`
    let response = await fetch(autoUrl);
    let data = await response.json();
    res.json(data);
});

// news
app.get('/api/news/:ticker', async (req, res) => {
    let ticker = req.params.ticker;
    let startDate = new Date();
    startDate.setMonth(startDate.getMonth() - 6);
    startDate.setDate(startDate.getDate() - 1);
    startDate = startDate.getFullYear() + '-' + 
    ('0' + (startDate.getMonth() + 1)).slice(-2) + '-' +
    ('0' + startDate.getDate()).slice(-2);
    let currentDate = new Date();
    let endDate = currentDate.getFullYear() + '-' +
    ('0' + (currentDate.getMonth() + 1)).slice(-2) + '-' +
    ('0' + currentDate.getDate()).slice(-2);
    let newsUrl = `https://finnhub.io/api/v1/company-news?symbol=${ticker}&from=${startDate}&to=${endDate}&token=${finnhub_key}`
    let response = await fetch(newsUrl);
    let data = await response.json();
    res.json(data);
});

// trend
app.get('/api/trend/:ticker', async (req, res) => {
    let ticker = req.params.ticker;
    let trendUrl = `https://finnhub.io/api/v1/stock/recommendation?symbol=${ticker}&token=${finnhub_key}`
    let response = await fetch(trendUrl);
    let data = await response.json();
    res.json(data);
});

// insight
app.get('/api/insight/:ticker', async (req, res) => {
    let ticker = req.params.ticker;
    let insightUrl = `https://finnhub.io/api/v1/stock/insider-sentiment?symbol=${ticker}&from=2022-01-01&token=${finnhub_key}`
    let response = await fetch(insightUrl);
    let data = await response.json();
    res.json(data);
});

// peers
app.get('/api/peers/:ticker', async (req, res) => {
    let ticker = req.params.ticker;
    let peersUrl = `https://finnhub.io/api/v1/stock/peers?symbol=${ticker}&token=${finnhub_key}`
    let response = await fetch(peersUrl);
    let data = await response.json();
    res.json(data);
});

// earnings
app.get('/api/earnings/:ticker', async (req, res) => {
    let ticker = req.params.ticker;
    let earningsUrl = `https://finnhub.io/api/v1/stock/earnings?symbol=${ticker}&token=${finnhub_key}`
    let response = await fetch(earningsUrl);
    let data = await response.json();
    res.json(data);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
