import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF4CAF50), // Xanh lá cây nhạt
        scaffoldBackgroundColor: Color(0xFFF1F8E9), // Nền nhạt xanh
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2E7D32), // Xanh đậm cho AppBar
          foregroundColor: Colors.white, // Đảm bảo chữ không chìm màu
        ),
        cardColor: Color(0xFF81C784), // Xanh nhạt cho Card
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  int _currentProductIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _scrollController = ScrollController();
    fetchVideos();
    fetchNews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Danh sách danh mục mẫu (ngắn gọn, ghi tắt)
  final List<Map<String, dynamic>> categories = [
    {'name': 'Gạo', 'icon': Icons.local_dining},
    {'name': 'Cà', 'icon': Icons.local_cafe},
    {'name': 'Phân', 'icon': Icons.local_florist},
    {'name': 'Máy', 'icon': Icons.build},
    {'name': 'Hạt', 'icon': Icons.grain},
    {'name': 'Thức', 'icon': Icons.fastfood},
    {'name': 'Thuốc', 'icon': Icons.healing},
    {'name': 'Nông', 'icon': Icons.agriculture},
  ];

  // Danh sách sản phẩm mẫu
  final List<Map<String, dynamic>> products = [
    {
      'title': 'Gạo ST25',
      'price': '12.000.000 đ',
      'image': 'https://via.placeholder.com/150',
      'location': 'Đồng Tháp',
      'seller': 'Nguyễn Văn A',
      'category': 'Nông sản',
    },
    {
      'title': 'Gỗ thông',
      'price': '8.000.000 đ',
      'image': 'https://via.placeholder.com/150',
      'location': 'Đà Lạt',
      'seller': 'Trần Thị B',
      'category': 'Lâm sản',
    },
    {
      'title': 'Cá tra',
      'price': '200.000 đ',
      'image': 'https://via.placeholder.com/150',
      'location': 'Cần Thơ',
      'seller': 'Lê Văn C',
      'category': 'Thủy sản',
    },
    {
      'title': 'Bò lai',
      'price': '25.000.000 đ',
      'image': 'https://via.placeholder.com/150',
      'location': 'Hà Nội',
      'seller': 'Phạm Thị D',
      'category': 'Chăn nuôi',
    },
    {
      'title': 'Bonsai',
      'price': '5.000.000 đ',
      'image': 'https://via.placeholder.com/150',
      'location': 'Huế',
      'seller': 'Hoàng Văn E',
      'category': 'Cây cảnh',
    },
    {
      'title': 'Chó becgie',
      'price': '15.000.000 đ',
      'image': 'https://via.placeholder.com/150',
      'location': 'TP.HCM',
      'seller': 'Ngô Thị F',
      'category': 'Thú nuôi',
    },
  ];

  // Danh sách video từ API
  List<dynamic> videos = [];
  // Danh sách bản tin từ API
  List<dynamic> news = [];

  // Hàm gọi API lấy danh sách video
  Future<void> fetchVideos() async {
    try {
      final response = await http.get(
        Uri.parse('https://api-ndolv2.nongdanonline.vn/api/v1/videos'),
        headers: {'Content-Type': 'application/json'},
      );

      print('API Video Response Status: ${response.statusCode}');
      print('API Video Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          videos = data['data'] ?? data['videos'] ?? [];
        });
      } else {
        print(
          'Failed to load videos: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching videos: $e');
    }
  }

  // Hàm gọi API lấy danh sách bản tin
  Future<void> fetchNews() async {
    try {
      final response = await http.get(
        Uri.parse('https://api-ndolv2.nongdanonline.vn/api/v1/news'),
        headers: {'Content-Type': 'application/json'},
      );

      print('API News Response Status: ${response.statusCode}');
      print('API News Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          news = data['data'] ?? data['news'] ?? [];
        });
      } else {
        print('Failed to load news: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  void _nextProduct() {
    if (_currentProductIndex < products.length - 1) {
      setState(() {
        _currentProductIndex++;
      });
      _scrollController.animateTo(
        _currentProductIndex * 168.0, // Độ rộng mỗi card + padding
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousProduct() {
    if (_currentProductIndex > 0) {
      setState(() {
        _currentProductIndex--;
      });
      _scrollController.animateTo(
        _currentProductIndex * 168.0, // Độ rộng mỗi card + padding
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chợ Tốt Nông Dân'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
          IconButton(icon: Icon(Icons.person), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Nông sản'),
            Tab(text: 'Thủy sản'),
            Tab(text: 'Chăn nuôi'),
            Tab(text: 'Lâm sản'),
            Tab(text: 'Cây cảnh'),
            Tab(text: 'Thú nuôi'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Thanh tìm kiếm
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm nông dân',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Color(0xFF4CAF50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Nội dung chính
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner quảng cáo
                Container(
                  height: 150,
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://via.placeholder.com/300x150',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Video nổi bật
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Video nổi bật',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                Container(
                  height: 150,
                  child:
                      videos.isEmpty
                          ? Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4CAF50),
                            ),
                          )
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: videos.length,
                            itemBuilder: (context, index) {
                              final video = videos[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            video['thumbnail'] ??
                                                video['image_url'] ??
                                                'https://via.placeholder.com/120x80',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      video['title'] ??
                                          video['name'] ??
                                          'Video ${index + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF2E7D32),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
                // Bản tin mới nhất
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Bản tin mới nhất',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                Container(
                  height: 100,
                  child:
                      news.isEmpty
                          ? Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4CAF50),
                            ),
                          )
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: news.length,
                            itemBuilder: (context, index) {
                              final item = news[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  width: 200,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] ?? 'Tin ${index + 1}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        item['date'] ?? '06/07/2025',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF81C784),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
                // Danh mục
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Danh mục nổi bật',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children:
                        categories.map((category) {
                          return Container(
                            width: 80,
                            height: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Color(0xFF81C784),
                                  child: Icon(
                                    category['icon'],
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  category['name'],
                                  style: TextStyle(color: Color(0xFF2E7D32)),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
                // Danh sách sản phẩm (slide kéo ngang với nút điều hướng)
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sản phẩm mới nhất',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Color(0xFF2E7D32),
                            ),
                            onPressed: _previousProduct,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF2E7D32),
                            ),
                            onPressed: _nextProduct,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height:
                      270, // Tăng chiều cao để chứa đầy đủ nội dung, tránh tràn
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          color: Color(0xFF81C784),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Container(
                            width: 160,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Color(0xFF81C784), // Đảm bảo nền đồng nhất
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize:
                                  MainAxisSize
                                      .min, // Tự động điều chỉnh chiều cao
                              children: [
                                Container(
                                  height: 150,
                                  width:
                                      144, // Điều chỉnh width để khớp với padding
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        products[index]['image'],
                                      ),
                                      fit: BoxFit.cover, // Đảm bảo lấp đầy
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  products[index]['title'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  products[index]['price'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Địa điểm: ${products[index]['location']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  'Người bán: ${products[index]['seller']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xFF2E7D32),
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Đăng tin',
      ),
    );
  }
}
