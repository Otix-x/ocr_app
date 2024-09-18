import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 5, right: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Card(
            color: Colors.blueAccent,
            child: Container(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.scanner,
                          size: 25,
                          color: Colors.white,
                        ),
                        Text(
                          'Scan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                  InkWell(
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner_outlined,
                          size: 25,
                          color: Colors.white,
                        ),
                        Text(
                          'Recognition',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                  InkWell(
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.adf_scanner,
                          size: 25,
                          color: Colors.white,
                        ),
                        Text(
                          'Enhance',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: Colors.black,
            child: Container(
              height: MediaQuery.of(context).size.height - 270,
            ),
          ),
          Card(
            color: Colors.blueAccent,
            child: Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    child: const Icon(
                      Icons.rotate_right_sharp,
                      size: 30,
                      color: Colors.white,
                    ),
                    onTap: () {},
                  ),
                  InkWell(
                    child: const Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: Colors.white,
                    ),
                    onTap: () {},
                  ),
                  InkWell(
                    child: const Icon(
                      Icons.image_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
