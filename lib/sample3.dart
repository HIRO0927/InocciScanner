class _ZaikoState extends State<Zaiko> {
  List<Widget> _items = <Widget>[];

  @override
  void initState() { //最初の表示
    super.initState();
    getItems();
  }

  static Database _db;
  String dbName = "database.db";

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, dbName);
    var exists = await databaseExists(path);
    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await io.Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join('assets',dbName));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await io.File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    return await openDatabase(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("残りの在庫"),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Text(_items.toString());
        }, //itemCount: _items.length,
      ),
    );
  }

  void getItems() async {
    List<Widget> list = <Widget>[];
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, "assets/database.db");

    //Directory dbPath = await getApplicationDocumentsDirectory();
    //String path = join(dbPath.path, "database.db");

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound){
            // Load database from asset and copy
            ByteData data = await rootBundle.load(join('assets', 'database.db'));
            List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

            // Save copied asset to documents
            await new File(path).writeAsBytes(bytes);
          }
        }
    );

    List<Map> result = await database.rawQuery('SELECT name FROM shoes');

    for (Map item in result) {
      list.add(
          ListTile(
            title: Text("${_items[index].name}"),
          )
      );
    }

    setState(() {
      _items = list;
    });
  }
}