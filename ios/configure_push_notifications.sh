#!/bin/bash

# Script to configure iOS Push Notifications entitlements
# Run this from the project root: bash ios/configure_push_notifications.sh

set -e

PROJECT_DIR="ios/Runner.xcodeproj"
PROJECT_FILE="$PROJECT_DIR/project.pbxproj"
ENTITLEMENTS_FILE="ios/Runner/Runner.entitlements"

echo "🔔 Configuring iOS Push Notifications..."

# Check if entitlements file exists
if [ ! -f "$ENTITLEMENTS_FILE" ]; then
    echo "✅ Creating entitlements file..."
    cat > "$ENTITLEMENTS_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>aps-environment</key>
	<string>development</string>
</dict>
</plist>
EOF
fi

# Check if project file exists
if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Error: Xcode project file not found at $PROJECT_FILE"
    exit 1
fi

# Add CODE_SIGN_ENTITLEMENTS to all build configurations
if grep -q "CODE_SIGN_ENTITLEMENTS" "$PROJECT_FILE"; then
    echo "✅ CODE_SIGN_ENTITLEMENTS already configured"
else
    echo "📝 Adding CODE_SIGN_ENTITLEMENTS to build configurations..."
    
    # Find all build configuration sections and add entitlements
    sed -i '' '/isa = XCBuildConfiguration;/a\
\			CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;' "$PROJECT_FILE"
    
    echo "✅ Added CODE_SIGN_ENTITLEMENTS to project"
fi

echo ""
echo "✅ Push notifications configuration complete!"
echo ""
echo "📋 Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Select Runner target → Signing & Capabilities"
echo "3. Add 'Push Notifications' capability"
echo "4. Ensure your provisioning profile includes Push Notifications"
echo "5. For production, change 'development' to 'production' in Runner.entitlements"
echo ""
