from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains



chrome_path = r"C:\Users\ss95\Desktop\chromedriver.exe"
driver = webdriver.Chrome(chrome_path)
driver.get("https://www.dailystrength.org/search?query=drug+interractions&type=discussion")

f = open('DailyStrength2.txt','w')
for i in range(99,199):
        driver.implicitly_wait(2)
        driver.execute_script("window.scrollTo(0, 0)") #Scroll up

        try:
                y = 10;
                if i > 100:
                        y = 15; #If post number exceeds 99, increase this value
                if i > 169:
                        y = 21;
                for x in range(y):
                            #print ('x=i=', x)
                            driver.execute_script("window.scrollTo(0, 0)") #Scroll up
                            driver.implicitly_wait(3)
                            show = driver.find_element_by_xpath("""//*[@id="show-more"]""")
                            ActionChains(driver).move_to_element(show).click(show).perform()
                            driver.implicitly_wait(3)
                            print("i:", i)
                            print("y:", y)
        except Exception as p:
                driver.get("https://www.dailystrength.org/search?query=drug+interractions&type=discussion")
                driver.execute_script("window.scrollTo(0, 0)") #Scroll up
                time.sleep(1)

                y = 10;
                if i > 100:
                           y = 15; #If post number exceeds 99, increase this value
                if i > 169:
                           y = 21;
                for x in range(y):
                            #print ('x=i=', x)
                            driver.execute_script("window.scrollTo(0, 0)") #Scroll up
                            driver.implicitly_wait(2)
                            show = driver.find_element_by_xpath("""//*[@id="show-more"]""")
                            ActionChains(driver).move_to_element(show).click(show).perform()
                            driver.implicitly_wait(2)
                            print("crashed")

        driver.execute_script("window.scrollTo(0, 0)") #Scroll up

        time.sleep(2)
        try:
                element = driver.find_element_by_xpath("""//*[@id="main-content"]/div[4]/div[2]/div[2]/div/ul/li[{0:d}]/div[1]/div[1]/h2/a""".format(i))
                print(element.text)
                ActionChains(driver).move_to_element(element).click(element).perform()
                time.sleep(2)
        except Exception as c:
                driver.get("https://www.dailystrength.org/search?query=drug+interractions&type=discussion")
                driver.execute_script("window.scrollTo(0, 0)") #Scroll up
                element = driver.find_element_by_xpath("""//*[@id="main-content"]/div[4]/div[2]/div[2]/div/ul/li[{0:d}]/div[1]/div[1]/h2/a""".format(i))
                print(element.text)
                ActionChains(driver).move_to_element(element).click(element).perform()
                time.sleep(2)
                print("crashed2")
                
        
        driver.execute_script("window.scrollTo(0, 0)") #Scroll up
       
        posts = driver.find_elements_by_class_name("posts__content")
        for post in posts:
                f.write("\n-------------------------------------------------------------------------------\n")
                f.write("Post:\n")
                f.write(post.text)

        comments = driver.find_elements_by_class_name("comments__comment")
        for comment in comments:
                f.write("\nComment(s):\n")
                f.write(comment.text)
        driver.implicitly_wait(3)
       # driver.execute_script("window.history.go(-1)") #driver.back didnt work all the time which makes it crash

        try:
            time.sleep(1)
            driver.back()

        except Exception as e:
            time.sleep(1)
            driver.get("https://www.dailystrength.org/search?query=drug+interractions&type=discussion")
            print("crashed3")
        driver.execute_script("window.scrollTo(0, 0)") #Scroll up

        print('Post number:', i)
        f.write(str(i))


f.close()
