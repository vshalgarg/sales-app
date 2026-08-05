import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/colors_used.dart';
import '../../customs/elevated_button.dart';
import '../../entry_document_upload/entry_upload_files.dart';

class BillEntryUploadDocuments extends StatefulWidget {
  final List<PlatformFile> files;
  final List<String> existingFileNames;
  final List<String> existingUrls;
  final bool isViewMode;
  final bool isEditMode;
  const BillEntryUploadDocuments({
    super.key,
    required this.files,
    required this.existingFileNames,
    required this.existingUrls,
    this.isViewMode = false,
    this.isEditMode = false,
  });

  @override
  State<BillEntryUploadDocuments> createState() => _BillEntryUploadDocumentsState();
}

class _BillEntryUploadDocumentsState extends State<BillEntryUploadDocuments> {
  List<PlatformFile> selectedFiles = [];
  @override
  void initState() {
    super.initState();
    selectedFiles = List<PlatformFile>.from(widget.files);
  }
  Future<void> selectFiles() async {
    final files = await pickFiles();

    if (files.isEmpty) return;

    for (final file in files) {
      if (!selectedFiles.any((e) => e.path == file.path)) {
        selectedFiles.add(file);
      }
    }

    if (selectedFiles.length > 3) {
      selectedFiles = selectedFiles.take(3).toList();
    }

    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Padding(
          padding: const EdgeInsets.only(left:15.0,right:15,top:15,bottom:10),

          child: Column(mainAxisSize: MainAxisSize.min,
              children: [
                Text("Bill Upload Documents",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                if (widget.existingFileNames.isNotEmpty)
                  Column(
                    children: List.generate(
                      widget.existingFileNames.length,
                          (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () async {
                              final uri = Uri.parse(widget.existingUrls[index]);

                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.existingFileNames[index],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  if (widget.isViewMode)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_red_eye,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        final uri = Uri.parse(widget.existingUrls[index]);

                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      },
                                    ),

                                  if (widget.isViewMode)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.download,
                                        color: Colors.green,
                                      ),
                                      onPressed: () async {
                                        final uri = Uri.parse(widget.existingUrls[index]);

                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      },
                                    ),

                                  if (widget.isEditMode)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          widget.existingFileNames.removeAt(index);
                                          widget.existingUrls.removeAt(index);
                                        });
                                      },
                                    ),
                                ],
                              )
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (selectedFiles.isNotEmpty)
                  Column(
                    children: selectedFiles.map((file) {

                      return InkWell(
                          onTap: () async {
                            if (file.path != null) {
                              final result = await OpenFilex.open(file.path!);
                            }
                          },
                          child: Container(
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
                      ));
                    }).toList(),
                  ),
                SizedBox(height:10),
                if (!widget.isViewMode &&
                    selectedFiles.length +
                        widget.existingFileNames.length <
                        3)
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
                SizedBox(height:15),
                Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomElevatedButton(
                      text: "Cancel",
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
