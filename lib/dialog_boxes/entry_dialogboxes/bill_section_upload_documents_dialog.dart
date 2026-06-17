import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../constants/colors_used.dart';
import '../../customs/elevated_button.dart';
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
      selectedFiles.addAll(files);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(mainAxisSize: MainAxisSize.min,
              children: [
                Text("Bill Upload Documents",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                if (selectedFiles.isNotEmpty)
                  Column(
                    children: selectedFiles.map((file) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.insert_drive_file,
                              size: 35,
                              color: Colors.blue,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  Text(
                                    "${(file.size / 1024).toStringAsFixed(2)} KB",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  selectedFiles.remove(file);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                SizedBox(height:10),
                if (selectedFiles.length < 3)
                GestureDetector(onTap:selectFiles,
                  child: Container(
                    decoration:BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:AppColors.primaryPurple,
                      )
                    ),
                    child:Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children:[
                         Container(
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
                          Text("Drag & drop files here\n or browse here",style:TextStyle(fontWeight:FontWeight.bold)),
                          Text("Supports JPG,PNG.JPEG & PDF ● Max 3 files ",style:TextStyle(color:Colors.grey)),

                        ]
                      ),
                    )
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomElevatedButton(
                      text: "cancel",
                      textStyle: TextStyle(color: Colors.black, fontSize: 20),
                      onPressed: ()async{Navigator.pop(context);},
                      borderRadius: 10,
                    ),
                    SizedBox(width: 20),
                    CustomElevatedButton(
                      text: "Save",
                      textStyle: TextStyle(color: Colors.white, fontSize: 20),
                      onPressed: ()async {
                        Navigator.pop(context, selectedFiles);
                      },
                      borderRadius: 10,
                      color: AppColors.primaryPurple,
                    ),
                  ],
                ),

              ]
          ),
        )
    );
  }
}
