//
// $Id: fishrdb.js 278 2009-01-13 01:33:33Z nicb $
//
// Javascript functions used in fishrdb
//
// sidebar menu functions
//
function scrollTo(top)
{
  var container = $('inner_menu');
  container.scrollTop = top;
}
function getElementPosition(dlink)
{
  var destx = dlink.offsetLeft;
  var desty = dlink.offsetTop;
  var thisNode = dlink;
  while (thisNode.offsetParent &&
      (thisNode.offsetParent != document.body))
  {
    thisNode = thisNode.offsetParent;
    destx += thisNode.offsetLeft;
    desty += thisNode.offsetTop;
  }
  return { x: destx, y: desty }
}
function menuScrollToActiveItem()
{
//  var item = $('activedocitem');
  var item = $('selected');
  if (item == null)
    return false; // if no active item return
  var menu = $('inner_menu');
  var itemPos = getElementPosition(item);
  var containerPos = getElementPosition(menu);
  var itemTop = itemPos.y - containerPos.y;
  var containerHeight = menu.offsetHeight - 35; //Hack: adjust for space by scrollbars
  if (itemTop + item.offsetHeight > menu.scrollTop + containerHeight ||
      itemTop < menu.scrollTop)
  {
    // item is not visible
    if (item.offsetHeight > containerHeight)
    { // item is too big to fit, so scroll to the top
      scrollTo(itemTop);
    }
    else
    {
      if (itemTop < menu.scrollTop + containerHeight)
      {
        // item is partially onscreen, so put whole item at bottom
        scrollTo(itemTop + item.offsetHeight - containerHeight);
      }
      else
      { // item is entirely offscreen, so center it
        scrollTo(itemTop - containerHeight/2 + item.offsetHeight/2);
      }
    }
  }
  return false;
}
