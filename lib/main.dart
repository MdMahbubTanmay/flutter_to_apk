import 'package:flutter/material.dart';

void main()
{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build (BuildContext context)
  {
    return MaterialApp(

      debugShowCheckedModeBanner: false,

      home: Scaffold(


        backgroundColor :const Color(0xFF0D0B14),

        appBar: AppBar(
          title: Text(
            'Test On Android',
            style: TextStyle(color: Colors.blueGrey),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF151224),


        ),

        body :
        
        Container(
          
          padding: EdgeInsets.all(15),

            
          
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
            Container(
              
              
              width: 200,
              height: 100,
              decoration: BoxDecoration(

              color: const Color(0xff161224),
                borderRadius: BorderRadius.circular(25),

                border: Border.all(
                  color: const Color(0xff3b2d54)
                )
              ),
              child:Center(
              child: 
              
              Text(
                
                'data', style: TextStyle(color: Color(0xffffffff)),),),

            ),

          ],),
       
        ),
      


      )
      
    );
  }
}