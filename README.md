# ezconfig.sh
A bash script to modify the plaintext config files with key/value sets

## Basic usage
```ezconfig.sh (File) (Operation) (Key) [Connector] (Value)```

`File` is the plaintext configuration file you would like to modify.

`Operation` can be one of the following options:

  - `set` updates the already available key/value set, or adds a new set to the end of the file. Completely ignores the sets that are commented out by `#`.
  - `reset` is like `set` but can uncomment and modify the already available key/value set in place if they are commented out by `#`, instead of adding a new set.
  - `autoset` is like `set` but does not prompt you if finds multiple matches available. Instead, modifies the last one.
  - `autoreset` is like `reset` does not prompt you if finds multiple matches available. Instead, modifies the last one.

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
Tip: you can put quotations around the arguments to modify the spacing! For example `ezconfig.sh ./php.ini set memory_limit ' = ' 2G` would generate `memory_limit = 2G`.

### Example 2. Setting the SSH port number to 22 in the config file /etc/ssh/sshd_config
```ezconfig.sh /etc/ssh/sshd_config set Port 5492```

Output:
```
> Matches before the processing:
15:Port  22
> Matches after the processing:
15:Port 5492
```
Note that here we skipped the `Connector` because we needed a space between "Port" and "5492" and the default connector is a space character. We could explicitly specify the connector:  ```ezconfig.sh /etc/ssh/sshd_config set Port ' ' 5492```

### Example 3. Updating the hostname in the hosts file
```ezconfig.sh /etc/hosts set 127.0.0.1 "$(hostname)"```

```
> Matches before the processing:
9:127.0.0.1 localhost
19:127.0.0.1     BabyServer
> There are 2 matches. I can modify only the last uncommented instance. Would you like to continue? (y/n)
```
Since here we have two key/value sets with identical keys ("127.0.0.1"), you need to confirm whether it's okay to update the second instance. If you wish to automatically confirm such actions, you can use `autoset` instead of `set`.

Tip: it's possible to use `ezconfig.sh /etc/hosts set "127.0.0.1 $(hostname)" "\n"` to search for the presence of both the key (127.0.0.1) and the value (the output of $(hostname)) together to avoid overwriting other hostnames that share the same IP. However, that usage is not recommended. 


## How to install
Run this command in your terminal:

```bash <(wget -qO- https://git.io/JUkKl)```


## Notes
- This script is not an appropriate tool for modifying files that contain multiple key/value sets with identical keys.
- Has only been tested on Ubuntu 20.04.
- Use it with caution!

