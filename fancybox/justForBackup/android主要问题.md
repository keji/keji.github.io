
### android 自定义控件配置参数
android如何获取LinearLayout的长和宽(getMeasuredWidth,getMeasuredHeight)
TableLayout stretchColumns
view.getLocationOnScreen(int[]) 获取控件坐标,在onCreate中返回0,在onWindowFocusChanged()返回正常
(RelativeLayout.LayoutParams)layoutParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT,RelativeLayout.TRUE)
获取控件截图 view.setDrawingCacheEnabled(true) Bitmap bitmap = view.getDrawingCache()
渐变色 GradientDrawable gradientDrawable = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM,new int[]{Color.RED,Color.BLUE});
顶部一个view,底部一个view中间的view充满,将顶部view设为wrap_content,底部view设为wrap_content中间view的weight=1
如果LinearLayout垂直排布,里面有两个button都设为layout_height都设为match_content,如果两个button全显示,需要设置layout_weight

TextView内容超链接:ClickableSpan

### 带下拉框的EditText -- AutoCompleteTextView
``` java
public void afterTextChanged(Editable s){
  Cursor cursor = database.rawQuery("select english as _id from t_words where english like ?",new String[]{s.toString() + "%"});
  DictionaryAdapter dictionaryAdapter = new DictionaryAdapter(this,cursor,true);
  autoCompleteTextView.setAdapter(dictionaryAdapter);
}
```
### 如何改变按钮的位置
方法1:
``` java
@Override
   public boolean onTouchEvent(MotionEvent event) {

       switch (event.getActionMasked()){

           case MotionEvent.ACTION_DOWN:
               initX = event.getX();
               initY = event.getY();
               break;

           case MotionEvent.ACTION_MOVE:
               float currentX = event.getX();
               float currentY = event.getY();

               offsetLeftAndRight((int)(currentX - initX));
               offsetTopAndBottom((int)(currentY - initY));

               initX = currentX;
               initY = currentY;
               return true;
       }


       return super.onTouchEvent(event);
   }
```
方法2:
``` java
float initX;
float initY;
@Override
public boolean onTouchEvent(MotionEvent event) {

    switch (event.getActionMasked()){

        case MotionEvent.ACTION_DOWN:
            initX = event.getX();
            initY = event.getY();
            break;

        case MotionEvent.ACTION_MOVE:
            float currentX = event.getX();
            float currentY = event.getY();

            ((ViewGroup)getParent()).scrollBy((int)(initX - currentX),(int)(initY - currentY));

            initX = currentX;
            initY = currentY;
            return true;
    }
    return super.onTouchEvent(event);
}
```
方法3:
``` java
@Override
public boolean onTouchEvent(MotionEvent event) {

    switch (event.getActionMasked()){

        case MotionEvent.ACTION_DOWN:
            initX = event.getX();
            initY = event.getY();
            break;

        case MotionEvent.ACTION_MOVE:
            float currentX = event.getX();
            float currentY = event.getY();

            int offsetX = (int)(currentX - initX);
            int offsetY = (int)(currentY - initY);

            layout(getLeft() + offsetX,getTop() + offsetY, getRight() + offsetX,getBottom() + offsetY);

            initX = currentX;
            initY = currentY;
            return true;
    }
    return super.onTouchEvent(event);
}
```

## 图片剪切技术

#### 1.显示一部分图片资源
``` java
Bitmap partBitmap = Bitmap.createBitmap(bitmap,200,200,400,400);
```

#### 2.下拉图片(进度条),图片剪切技术
``` java

<?xml version="1.0" encoding="utf-8"?>
<clip xmlns:android="http://schemas.android.com/apk/res/android"
    android:clipOrientation="vertical"
    android:drawable="@drawable/aaa"
    android:gravity="top"
    >

</clip>

ImageView imageView = (ImageView)findViewById(R.id.center_imageview);
      final ClipDrawable clipDrawable = (ClipDrawable) imageView.getDrawable();
      clipDrawable.setLevel(0);

      final ValueAnimator animation = ValueAnimator.ofInt(0,10000);
      animation.setDuration(4000);
      animation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
          @Override
          public void onAnimationUpdate(ValueAnimator animation) {
              int value = (Integer)animation.getAnimatedValue();
              clipDrawable.setLevel(value);
          }
      });
animation.start();
```
### AAR文件包的用法
