package com.github.jdablooms;

import static org.junit.Assert.*;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

public class ScaleBloomFilterTest {

	public static int CAPACITY = 20;
	public static double ERROR_RATE = .01;

	public static String TEXT = "Greatest properly off ham exercise all. Unsatiable invitation its possession nor off. All difficulty estimating unreserved increasing the solicitude. Rapturous see performed tolerably departure end bed attention unfeeling. On unpleasing principles alteration of. Be at performed preferred determine collected. Him nay acuteness discourse listening estimable our law. Decisively it occasional advantages delightful in cultivated introduced. Like law mean form are sang loud lady put. Him rendered may attended concerns jennings reserved now. Sympathize did now preference unpleasing mrs few. Mrs for hour game room want are fond dare. For detract charmed add talking age. Shy resolution instrument unreserved man few. She did open find pain some out. If we landlord stanhill mr whatever pleasure supplied concerns so. Exquisite by it admitting cordially september newspaper an. Acceptance middletons am it favourable. It it oh happen lovers afraid.There worse by an of miles civil. Manner before lively wholly am mr indeed expect. Among every merry his yet has her. You mistress get dashwood children off. Met whose marry under the merit. In it do continual consulted no listening. Devonshire sir sex motionless travelling six themselves. So colonel as greatly shewing herself observe ashamed. Demands minutes regular ye to detract is. ";

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		System.out.println("library path = " + System.getProperty("java.library.path"));

	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {

	}

	@Test
	public void testString() {
		String[] words = TEXT.split("\\W+");
		ScaleBloomFilter bf = new ScaleBloomFilter(CAPACITY, ERROR_RATE);

		for (int i = 0; i < words.length; i++) {
			if (i % 5 == 0) {
				bf.put(words[i]);
			}
		}
		for (int i = 0; i < 20; i++) {
			bf.put("WQRD");
		}

		int bad = 0;
		for (int i = 0; i < words.length; i++) {
			if (i % 5 == 0) {
				assertEquals(true, bf.mightContain(words[i]));
			} else {
				if (bf.mightContain(words[i])) {
					bad += 1;
				}
			}
		}
		System.out.println("False positive rate is  " + (1.0 * bad / words.length));
		System.out.println("#words= " + words.length);
		System.out.println("Count= " + bf.count());
		bf.close();
	}

	@Test
	public void testBytes() {
		String[] awords = TEXT.split("\\W+");
		ScaleBloomFilter bf = new ScaleBloomFilter(CAPACITY, ERROR_RATE);

		for (int i = 0; i < awords.length; i++) {
			if (i % 5 == 0) {
				bf.put(awords[i].getBytes());
			}
		}
	 
		int bad = 0;
		for (int i = 0; i < awords.length; i++) {
			if (i % 5 == 0) {
				assertEquals(true, bf.mightContain(awords[i].getBytes()));
			} else {
				if (bf.mightContain(awords[i].getBytes())) {
					bad += 1;
				}
			}
		}
		System.out.println("False positive rate is  " + (1.0 * bad / awords.length));
		System.out.println("#words= " + awords.length);
		System.out.println("Count= " + bf.count());
		bf.close();
	}

}
