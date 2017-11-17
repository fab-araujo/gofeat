<?php
class Plugin_Util {
	
	public function dataHoraToDb($data){
		$date = new Zend_Date($data, "dd/MM/YYYY HH:mm:ss");
		
		return $date->toString('YYYY-MM-dd HH:mm:ss');	
	}
	
	public function dataToDb($data){
		$date = new Zend_Date($data, "dd/MM/YYYY");
	
		return $date->toString('YYYY-MM-dd');
	}
	
	public function dataHoraToSite($data){
		$date = new Zend_Date($data, "YYYY-MM-dd HH:mm:ss");
		
		return $date->toString('dd/MM/YYYY HH:mm:ss');	
	}
	
	public function dataToSite($data){
		
		$date = new Zend_Date($data, "YYYY-MM-dd");
	
		return $date->toString('dd/MM/YYYY');
	}

	public function arquivo($arquivo){
		if ($arquivo && is_file($_SERVER['DOCUMENT_ROOT'] . '/data/' . $arquivo)){
			return true;
		}
		return false;
	}

    function pretty_json($json) {

        $result      = '';
        $pos         = 0;
        $strLen      = strlen($json);
        $indentStr   = '  ';
        $newLine     = "\n";
        $prevChar    = '';
        $outOfQuotes = true;

        for ($i=0; $i<=$strLen; $i++) {

            // Grab the next character in the string.
            $char = substr($json, $i, 1);

            // Are we inside a quoted string?
            if ($char == '"' && $prevChar != '\\') {
                $outOfQuotes = !$outOfQuotes;

                // If this character is the end of an element,
                // output a new line and indent the next line.
            } else if(($char == '}' || $char == ']') && $outOfQuotes) {
                $result .= $newLine;
                $pos --;
                for ($j=0; $j<$pos; $j++) {
                    $result .= $indentStr;
                }
            }

            // Add the character to the result string.
            $result .= $char;

            // If the last character was the beginning of an element,
            // output a new line and indent the next line.
            if (($char == ',' || $char == '{' || $char == '[') && $outOfQuotes) {
                $result .= $newLine;
                if ($char == '{' || $char == '[') {
                    $pos ++;
                }

                for ($j = 0; $j < $pos; $j++) {
                    $result .= $indentStr;
                }
            }

            $prevChar = $char;
        }

        return $result;
    }

    function encrypt($string) {
        $output = false;

        $encrypt_method = "AES-256-CBC";
        $secret_key = 'b4d is awesome';
        $secret_iv = 'b4d is awesome';

        // hash
        $key = hash('sha256', $secret_key);

        // iv - encrypt method AES-256-CBC expects 16 bytes - else you will get a warning
        $iv = substr(hash('sha256', $secret_iv), 0, 16);

        $output = openssl_encrypt($string, $encrypt_method, $key, 0, $iv);
        $output = base64_encode($output);

        return $output;
    }

    function decrypt($string) {
        $output = false;

        $encrypt_method = "AES-256-CBC";
        $secret_key = 'b4d is awesome';
        $secret_iv = 'b4d is awesome';

        // hash
        $key = hash('sha256', $secret_key);

        // iv - encrypt method AES-256-CBC expects 16 bytes - else you will get a warning
        $iv = substr(hash('sha256', $secret_iv), 0, 16);

        $output = openssl_decrypt(base64_decode($string), $encrypt_method, $key, 0, $iv);

        return $output;
    }
}