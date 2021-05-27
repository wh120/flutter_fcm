# flutter_fcm
Firebase Cloud Messaging (FCM)  Flutter package.

## Why flutter_fcm?

- 🚀 Easy to use 
- ⚡ Supports local notification


## Getting Started

### 🔩 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_fcm:
    git:
      url: https://github.com/wh120/flutter_fcm.git
```

## Using

The easiest way to use this library is via the top-level functions.

```dart
import 'package:flutter_fcm/flutter_fcm.dart';

init()async{
  try{
    await FCM.initializeFCM(
      onData: (Map<String, dynamic> data) {
        print(data);
      },
      onTokenChanged: (String token) {
        print(token);
      },
      icon: 'stem_cells'
    );
  }catch(e){}
}
```
 

  
