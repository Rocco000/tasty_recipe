import 'package:flutter/material.dart';

class CategoryCardWidget extends StatelessWidget {
  final String label;
  final String background;
  final void Function() onTap;

  const CategoryCardWidget({
    required this.label,
    required this.background,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Card(
          color: Colors.white,
          shadowColor: Colors.orange[200],
          elevation: 10.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // IMAGE AS BACKGROUND
              Image.asset(
                background,
                fit: BoxFit.cover,
              ),
              /*Container(
                width: double.infinity,
                //height: 180,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: background,
                    fit: BoxFit.cover,
                  ),
                ),
              ),*/
        
              Positioned(
                left: 0.0,
                bottom: 0.0,
                right: 0.0,
                child: ColoredBox(
                  color: Colors.black38,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ListTile(
                      title: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white,),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
