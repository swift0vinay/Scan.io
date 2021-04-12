package com.scan.io;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.ColorMatrix;
import android.graphics.ColorMatrixColorFilter;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Picture;
import android.graphics.PorterDuff;
import android.graphics.Typeface;
import android.graphics.pdf.PdfDocument;
import android.os.Environment;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.*;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

class SimpleFileModel {
    String filePath;
    int filterType;

    SimpleFileModel(String filePath, int filterType) {
        this.filePath = filePath;
        this.filterType = filterType;
    }
}

public class MainActivity extends FlutterActivity {
    int pageHeight = 0;
    int pagewidth = 0;
    String directoryPath;
    String fileName;

    ArrayList<HashMap<String, Object>> al = new ArrayList<>();
    ArrayList<SimpleFileModel> filePaths = new ArrayList<>();
    static final String methodChannel = "SCAN_IO";

    final float[][] filterConstants = {
            // No Filter
            {1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f},
            // Black And White
            {0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f},
            // Lighten
            {1.5f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.5f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.5f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f},
            // Darken
            {0.5f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.5f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.5f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f},
            // GrayScale
            {1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f},
            // Invert
            {-1.0f, 0.0f, 0.0f, 0.0f, 255.0f, 0.0f, -1.0f, 0.0f, 0.0f, 255.0f, 0.0f, 0.0f, -1.0f, 0.0f, 255.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f},
            // Sepia
            {0.393f, 0.769f, 0.189f, 0f, 0f, 0.349f, 0.686f, 0.168f, 0f, 0f, 0.272f, 0.534f, 0.131f, 0f, 0f, 0f, 0f, 0f, 1f, 0f},
    };

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor(), methodChannel).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                if (call.method.equals("create")) {
                    al.clear();
                    filePaths.clear();
                    pageHeight = call.argument("height");
                    pagewidth = call.argument("width");
                    al = call.argument("files");
                    for (HashMap<String, Object> hm : al) {
                        SimpleFileModel model = new SimpleFileModel((String) hm.get("filePath"), (int) hm.get("filterType"));
                        filePaths.add(model);
                    }
                    directoryPath = call.argument("directoryPath");
                    fileName = call.argument("fileName");
                    createPdf();
                    result.success(1);
                }
            }
        });
    }

    private void createPdf() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            PdfDocument document = new PdfDocument();
            Canvas canvas;
            PdfDocument.PageInfo pageInfo;
            PdfDocument.Page page;
            Bitmap bitmap, scaledBitmap;
            int pageNumber = 1;

            for (SimpleFileModel model : filePaths) {
                Paint paint = null;
                if (model.filterType != -1) {
                    ColorMatrix colorMatrix = new ColorMatrix();
                    colorMatrix.set(filterConstants[model.filterType]);
                    ColorMatrixColorFilter colorFilter = new ColorMatrixColorFilter(colorMatrix);
                    paint = new Paint();
                    paint.setColorFilter(colorFilter);
                }
                bitmap = BitmapFactory.decodeFile(model.filePath);
                int MAX_WIDTH = 900, MAX_HEIGHT = 1300;
                float scale = Math.min(MAX_WIDTH / (float) bitmap.getWidth(),
                        MAX_HEIGHT / (float) bitmap.getHeight());
                Matrix matrix = new Matrix();
                matrix.postScale(scale, scale);
                scaledBitmap = Bitmap.createBitmap(bitmap, 0, 0,
                bitmap.getWidth(), bitmap.getHeight(), matrix, false);
                 pageInfo = new PdfDocument.PageInfo.Builder( scaledBitmap.getWidth(), scaledBitmap.getHeight(), pageNumber).create();
                page = document.startPage(pageInfo);
                canvas = page.getCanvas();
                // int top = (1300 - scaledBitmap.getHeight()) / 2;
                // int left = (900 - scaledBitmap.getWidth()) / 2;
                canvas.drawBitmap(scaledBitmap, 0, 0, paint);
                document.finishPage(page);
                ++pageNumber;
            }

            String filePath = directoryPath + "/" + fileName + ".pdf";
            Log.w("asfas", "F{" + filePath);
            try {
                FileOutputStream fileOutputStream = new FileOutputStream(filePath);
                document.writeTo(fileOutputStream);
                Log.w("error", "Success");
            } catch (IOException e) {
                Log.w("error", "Errror encountered");
                e.printStackTrace();
            }
            document.close();
        }

    }

}
