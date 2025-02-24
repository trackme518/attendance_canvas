import java.io.UnsupportedEncodingException;
import java.security.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import java.util.Base64;

//import javax.xml.bind.DatatypeConverter;

//import org.apache.commons.codec.binary.Hex;

//I am using symmetric crypto AES - assymetrical would be better (RSA)
//but since I am checking the lic offline anyway it does not make sense
//because the checking code has to be in this program anyway

String cryptoPass = "LK%jbv2Rq7eMFf5FvyRvWoKh2XOH9CpJ";

String encrypter(String message, String key) { //Encrypter //String key, String initVector

  String base64_encrypted = "";
  try {
    SecretKeySpec skeySpec_encode = new SecretKeySpec(key.getBytes("UTF-8"), "AES");
    // Cipher cipher_encode = Cipher.getInstance("AES/ECB/PKCS7PADDING");
    Cipher cipher_encode = Cipher.getInstance("AES/ECB/PKCS5PADDING");
    cipher_encode.init(Cipher.ENCRYPT_MODE, skeySpec_encode);
    //  Cipher cipher_encode = Cipher.getInstance("AES/CBC/PKCS5PADDING"); //AES-CBC with IV encoding, ECB is used without the IV, example shown on <a href="http://aesencryption.net/" target="_blank" rel="nofollow">http://aesencryption.net/</a>
    //   cipher_encode.init(Cipher.ENCRYPT_MODE, skeySpec_encode, iv_encode);

    byte[] encrypted = cipher_encode.doFinal(message.getBytes());
    //encode without padding: Base64.getEncoder().withoutPadding().encodeToString(encrypted));
    //encode with padding:  Base64.getEncoder().encodeToString(encrypted));

    base64_encrypted = new String( Base64.getEncoder().encode(encrypted) );
  }
  catch (Exception ex) {
    ex.printStackTrace();
  }
  return base64_encrypted;
}

String decrypter(String base64_encrypted, String key) {  //Decrypter // String decrypter(String base64_encrypted, String key, String initVector)

  String decrypt_originalString="";

  try {
    //    IvParameterSpec iv_decode = new IvParameterSpec(initVector.getBytes("UTF-8"));
    SecretKeySpec skeySpec_decode = new SecretKeySpec(key.getBytes("UTF-8"), "AES");

    // Cipher cipher_decode = Cipher.getInstance("AES/CBC/PKCS5PADDING");
    Cipher cipher_decode = Cipher.getInstance("AES/ECB/PKCS5PADDING");
    //Cipher cipher_decode = Cipher.getInstance("AES/ECB/PKCS7PADDING"); //not supported :-(

    //cipher_decode.init(Cipher.DECRYPT_MODE, skeySpec_decode, iv_decode);
    cipher_decode.init(Cipher.DECRYPT_MODE, skeySpec_decode);
    
    byte[] decrypted_original = cipher_decode.doFinal( Base64.getDecoder().decode(base64_encrypted) ) ;

    decrypt_originalString = new String(decrypted_original);
  }

  catch (Exception ex) {
    ex.printStackTrace();
  }

  return decrypt_originalString;
}

private String generateSafeToken(int stringLength) {
  //int bytes = 4*(n/3); //other way round
  int bytesLength = (stringLength*3) /4; //how many bytes needed for base64 char string of given length?
  SecureRandom random = new SecureRandom();
  byte bytes[] = new byte[bytesLength];
  random.nextBytes(bytes);
  String token = Base64.getEncoder().withoutPadding().encodeToString(bytes); //without padding
  //String token = Base64.getEncoder().encodeToString(bytes);//with padding
  return token;
}
