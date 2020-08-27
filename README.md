# ezconfig.sh
A bash script to modify the plaintext config files with key/value sets

## Basic usage
```ezconfig.sh (File) (Operation) (Key) [Connector] (Value)```

`File` is the plaintext configuration file you would like to modify.

`Operation` can be one of the following options:

  - `set` first attempts to update the last preexisting key/value that is NOT commented out by `#`. If a matching key does not exist, a new key/value set will be added to the end of the file.
  - `reset` is like `set` but first attempts to uncomment and modify the already available key/value set in place if they are commented out by `#`.
  - `autoset` is like `set` but does not prompt you if finds multiple matches. Instead, modifies the last one.
  - `autoreset` is like `reset` does not prompt you if finds multiple matches. Instead, modifies the last one.

`Key` is the first part of a key/value set.

`Connector` is the character that should be placed between the key and value. The default is space.

`Value` is the second part of a key/value set.


## Examples
### Example 1. Setting the PHP memory limit to 2G
```ezconfig.sh ./php.ini set memory_limit = 2G```

Output:
```
> Matches before the processing:
401:memory_limit = -1
> Matches after the processing:
401:memory_limit=2G
```
Tip: you can put quotations around the arguments to modify the spacing! For example `ezconfig.sh ./php.ini set memory_limit ' = ' 2G` would generate `memory_limit = 2G`. Notice that line numbers of the matches are shown in the output.

### Example 2. Setting the SSH port number to 22 in the config file /etc/ssh/sshd_config
By default, the port number line in /etc/ssh/sshd_config is commented out (`#Port 22`). So, instead of using `set` that adds the setting to the end of the file, we can use `reset` to uncomment and modify the preexisting setting in place (if `reset` cannot find a match, it will act like `set`).

```ezconfig.sh /etc/ssh/sshd_config reset Port 5492```

Output:
```
> Matches before the processing:
15:#Port 22
> I can uncomment and modify the matched instance. Would you like to continue? (y/n)
```
Now we hit the `y` key to agree (if you wish to automatically confirm such actions, you can use `autoreset` instead of `reset`)
```
> Matches after the processing:
15:Port 5492
```
Note that here we skipped the `Connector` because we needed a space between "Port" and "5492" and the default connector is a space character. We could explicitly specify the connector:  ```ezconfig.sh /etc/ssh/sshd_config set Port ' ' 5492```.

### Example 3. Exporting variables

```
MY_TIMEZONE='America/New_York'
ezconfig.sh ~/.bashrc set 'export APP_TIMEZONE' = "'${MY_TIMEZONE}'"
```
Output:
```
> Matches after the processing:
114:export APP_TIMEZONE='America/New_York'
```

### Example 4. Updating the hostname in the hosts file
```
hostnamectl set-hostname "NewServer"
ezconfig.sh /etc/hosts autoset 127.0.0.1 "$(hostname)"
```

Output:
```
> Matches before the processing:
9:127.0.0.1 localhost
19:127.0.0.1     OldServer
> Matches after the processing:
9:127.0.0.1 localhost
19:127.0.0.1 NewServer
```
Since here we have two key/value sets with identical keys ("127.0.0.1"), you need to confirm whether it's okay to update the second instance (since we used `autoset`, that was confirmed automatically).

Tip: it's possible to use `ezconfig.sh /etc/hosts set "127.0.0.1 $(hostname)" "\n"` to avoid overwriting other hostnames that share the same IP. However, this usage is not recommended. 


## How to install
Run this command in your terminal:

```bash <(wget -qO- https://git.io/JUkKl)```


## Notes
- This script is not an appropriate tool for modifying files that can contain multiple key/value sets with identical keys.
- Has only been tested on Ubuntu 20.04.
- If you are specifying the connector, make sure to put space around it (`key=val` is INCORRECT. Should be ` key = val`)
- When using `reset` or `autoreset` be aware that this script does not distinguish between a **comment** and a **commented out key/value set**. So, if you try `ezconfig.sh file reset mykey myvalue`, a comment like `#mykey is a key of mine` is as likely to be affected as `#mykey 123`.

