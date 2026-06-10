import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../constants/colors_used.dart';
import '../../entry_document_upload/entry_upload_files.dart';

class BillEntryUploadDocuments extends StatefulWidget {
  const BillEntryUploadDocuments({super.key});

  @override
  State<BillEntryUploadDocuments> createState() => _BillEntryUploadDocumentsState();
}

class _BillEntryUploadDocumentsState extends State<BillEntryUploadDocuments> {
  List<PlatformFile> selectedFiles = [];

  Future<void> selectFiles() async {
    final files = await pickFiles();

    setState(() {
      selectedFiles = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(
            children: [
              Text("Bill Upload Documents",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
              SizedBox(height:10),
              Container(
                decoration:BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:AppColors.primaryPurple,
                  )
                ),
                child:Column(
                  children:[
                GestureDetector(
                  onTap:()async{await selectFiles();},
                  child: Container(
                  decoration: BoxDecoration(
                  color: AppColors.primaryPurpleLight,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Center(
                      child: Icon(
                        Icons.cloud_download_rounded,
                        color: AppColors.primaryPurple,
                        size: 22,
                      ),
                    ),
                  ),
                                ),
                ),
                    Text("Drag & drop files here\n or browse here",style:TextStyle(fontWeight:FontWeight.bold)),
                    Text("Supports JPG,PNG.JPEG & PDF ● Max # files ")
                  ]
                )
              )

            ]
        )
    );
  }
}
