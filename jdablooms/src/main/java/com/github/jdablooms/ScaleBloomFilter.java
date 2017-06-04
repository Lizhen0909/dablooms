package com.github.jdablooms;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.UUID;

public class ScaleBloomFilter {
	private scaling_bloom_t filter;
	private long count = 0;
	private String filename;

	public ScaleBloomFilter(long expectedElements, double falsePositiveRate) {
		ScaleBloomFilter.load_native();
		this.filename = System.getProperty("java.io.tmpdir") + "/scale_bloom_" + UUID.randomUUID().toString();
		this.filter = cdablooms.new_scaling_bloom(expectedElements, falsePositiveRate);
	}

	public void close() {
		cdablooms.free_scaling_bloom(filter);
		new File(this.filename).delete();
	}

	public static void loadLibraryFromJar(String path) throws IOException {

		if (!path.startsWith("/")) {
			throw new IllegalArgumentException("The path has to be absolute (start with '/').");
		}

		// Obtain filename from path
		String[] parts = path.split("/");
		String filename = (parts.length > 1) ? parts[parts.length - 1] : null;

		// Split filename to prexif and suffix (extension)
		String prefix = "";
		String suffix = null;
		if (filename != null) {
			parts = filename.split("\\.", 2);
			prefix = parts[0];
			suffix = (parts.length > 1) ? "." + parts[parts.length - 1] : null; // Thanks,
																				// davs!
																				// :-)
		}

		// Check if the filename is okay
		if (filename == null || prefix.length() < 3) {
			throw new IllegalArgumentException("The filename has to be at least 3 characters long.");
		}

		// Prepare temporary file
		File temp = File.createTempFile(prefix, suffix);
		temp.deleteOnExit();

		if (!temp.exists()) {
			throw new FileNotFoundException("File " + temp.getAbsolutePath() + " does not exist.");
		}

		// Prepare buffer for data copying
		byte[] buffer = new byte[1024];
		int readBytes;

		// Open and check input stream
		InputStream is = ScaleBloomFilter.class.getResourceAsStream(path);
		if (is == null) {
			throw new FileNotFoundException("File " + path + " was not found inside JAR.");
		}

		// Open output stream and copy data between source file in JAR and the
		// temporary file
		OutputStream os = new FileOutputStream(temp);
		try {
			while ((readBytes = is.read(buffer)) != -1) {
				os.write(buffer, 0, readBytes);
			}
		} finally {
			// If read/write fails, close streams safely before throwing an
			// exception
			os.close();
			is.close();
		}

		// Finally, load the library
		System.load(temp.getAbsolutePath());
		new File(temp.getAbsolutePath()).delete();
	}

	public static void load_native() {
		try {
			ScaleBloomFilter.loadLibraryFromJar("/native/libdablooms_jni.so");
		} catch (IOException e1) {
			throw new RuntimeException(e1);
		}
	}

	public void put(String w) {
		count += 1;
		cdablooms.scaling_bloom_add(filter, w, w.length(), count);

	}

	public boolean mightContain(String w) {
		return cdablooms.scaling_bloom_check(filter, w, w.length()) > 0;

	}

	public void put(byte[] w) {
		count += 1;
		cdablooms.scaling_bloom_add_bytes(filter, w, count);

	}

	public boolean mightContain(byte[] w) {
		return cdablooms.scaling_bloom_check_bytes(filter, w) > 0;

	}

	public long count() {
		return cdablooms.scaling_bloom_count(filter);
	}

	public boolean check(String w) {
		return mightContain(w);

	}

}
